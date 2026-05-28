# 7a. AI, third-party risk & due diligence

All AI + external-risk work runs in **Supabase Edge Functions** (Deno). The browser
never holds a key. One shared gateway abstracts the LLM provider; one shared
`risk-screening` function abstracts external risk data with a **mock mode** so the
demo never depends on a flaky API.

## 7a.1 Edge functions (deploy all)

| Function | Purpose | Caller | Writes |
|----------|---------|--------|--------|
| `_shared/ai.ts` | provider-agnostic LLM call (chat + vision + JSON mode) | (import) | — |
| `_shared/cors.ts` | CORS headers + preflight | (import) | — |
| `extract-document` | OCR/vision a doc → `{doc_type, requirement_key, fields}` | vendor onboarding dropzone | `vendor_documents.extracted_data` |
| `mca-fetch` | PAN/CIN → entity + directors | Company Profile "Auto-Fetch from MCA" | (returns; client writes) |
| `vendor-web-insights` | build AI dossier + call risk-screening | 360 "Refresh Now" | `vendor_web_insights`, `vendor_news_items`, `vendor_risk_screenings` |
| `risk-screening` | sanctions/pep/credit/news/geographic (pluggable, mock+live) | web-insights, DD gate | `vendor_risk_screenings` |
| `ai-evaluate` | suggest scorecard scores w/ rationale + data source | Evaluation "AI suggest scores" | (returns; client writes lines) |
| `vendor-assistant` | onboarding chat helper ("Aiera"); can fill a field | wizard side panel | — |
| `send-vendor-notification` | in-app notification + email (Resend) | all key events | `notifications` (+ email) |
| `expiry-sweep` | mark expired docs + queue reminders (cron) | pg_cron / scheduler | `vendor_documents`, `notifications` |

**Secrets:** `AI_PROVIDER` (default `openai`), `OPENAI_API_KEY`, `GEMINI_API_KEY`,
optional `ANTHROPIC_API_KEY`; `RISK_MODE` (default `mock`), `OPENSANCTIONS_API_KEY`,
`NEWS_API_KEY`, `MCA_API_KEY`, `DNB_API_KEY`; `RESEND_API_KEY`,
`SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`.

## 7a.2 Document extraction → auto-map (the headline AI feature)

Flow when a vendor drops files on the onboarding dropzone:
1. Client uploads each file to Storage `vendor-documents/{vendor_id}/inbox/{uuid}.{ext}`.
2. Client calls `extract-document` with `{vendor_id, storage_path, mime}`.
3. Function downloads the file (service role), sends image/PDF to the **vision**
   model with a strict JSON schema prompt, and returns:
   ```json
   {
     "doc_type": "gst_certificate",
     "requirement_key": "gst",
     "confidence": 0.94,
     "fields": {
       "gstin": "27AAACT2727Q1ZV", "legal_name": "Tata Steel Limited",
       "state": "Maharashtra", "jurisdiction_code": "27",
       "pan": "AAACT2727Q", "address": "Bombay House…",
       "issue_date": "2017-07-01", "expires_at": null,
       "cert_number": null, "issuer": null
     }
   }
   ```
4. Client **maps `fields` into the matching wizard step** (a `FIELD_MAP` keyed by
   `doc_type`) and **files the document into its `requirement_key` slot**
   (`vendor_documents` row with status `uploaded`, `extracted_data` saved, move file
   from `/inbox/` to `/{requirement_key}.{ext}`). Shows a green "matched" chip.
5. Low confidence (<0.6) → leave field empty + flag for manual entry (don't guess).

**doc_type → step/field map** (client constant):
| doc_type | requirement_key | fills |
|----------|-----------------|-------|
| pan_card | pan | Company: pan, legal_name |
| gst_certificate | gst | Tax Reg: registration_number, jurisdiction(+code), address |
| incorporation_certificate | coi | Company: cin, incorporation_date, entity_type |
| iso_9001 / iso_14001 / iso_27001 | iso_* | Qualification.certifications: cert_type, issuer, valid_until, cert_number |
| bank_proof | bank_proof | Banking: account_holder, account_number, ifsc, bank_name, branch |
| insurance | insurance | Documents only (+ expires_at) |
| financial_statement | — | Qualification: turnover_y*, net_worth, auditor |

## 7a.3 Third-party risk & screening (`risk-screening`)

`risk-screening({vendor_id, types[], mode})` runs each requested screening through a
provider adapter, writes a `vendor_risk_screenings` row per type, returns a summary.

| type | live provider | mock behaviour |
|------|---------------|----------------|
| `sanctions` | OpenSanctions `/match` on legal_name+directors | status `clean`, entities_checked = #directors+1, hits 0 |
| `pep` | OpenSanctions PEP dataset | status `clean`, persons = #directors |
| `credit` | D&B / CRISIL (or manual) | rating from seed (CRISIL AA/Stable, D&B 5A1) |
| `news` | NewsAPI/GDELT → AI sentiment | seeded headlines + AI/seeded sentiment |
| `geographic` | static country-risk index by state/country | "Stable economy" score |
| `adverse_media` | AI summary over news | AI summary or "no material adverse media" |

`RISK_MODE=mock` (default for demos) returns deterministic, believable results
instantly; `live` calls the real adapters and falls back to mock on error
(`result.degraded=true`). Every run writes audit `screening_complete`.

## 7a.4 Due-diligence workflow (woven into approval)

Due diligence is a **gate between `under_review` and `approved`**, not a separate
silo. The 360 shows a DD checklist; **Approve** stays disabled until it passes.

```
submitted ─▶ under_review
                │  Due-diligence checklist (buyer):
                │   1. Documents verified            (vendor_documents.status='verified' for all mandatory)
                │   2. Risk screenings run + clean   (vendor_risk_screenings: sanctions+pep not 'flagged')
                │   3. Web Insights refreshed        (vendor_web_insights.refreshed_at present)
                │   4. Scorecard complete            (vendor_scorecards.status='complete')
                │   5. Composite ≥ threshold OR override note
                ▼
   gate passed → enable Approve → vendor_transition('approved')
   gate failed → Request changes / Reject, or score with override note
```

- Result recorded on `vendor_approvals.due_diligence_passed` + a note. The
  re-evaluation triggers (time/event/transaction) from the Evaluation tab create
  follow-up `notifications`/tasks via `expiry-sweep`/event hooks (P2).
- The **DD checklist** is a computed selector on the client (reads the 5 conditions)
  — no new table needed; every input already persists.

## 7a.5 Prompts (sketch — keep server-side, JSON mode)

- **extract-document (vision):** "You are a procurement document parser. Identify the
  document type from this set [...]. Return ONLY JSON matching this schema [...].
  Extract Indian identifiers exactly (PAN 10 chars, GSTIN 15 chars, IFSC 11).
  If a field is absent, use null. Never invent values."
- **ai-evaluate:** "Given this vendor profile + signals [...], for each criterion
  propose an integer score 1–5, the data_source it's based on, and a one-line basis.
  Conservative when evidence is thin. Return JSON array."
- **vendor-web-insights:** "Summarise this company for a procurement risk dossier:
  overview (≤60 words), key personnel, financial snapshot, 4–6 recent news items with
  sentiment. India-context. JSON only."
- **vendor-assistant:** system = "You are Aiera, Aerchain's onboarding assistant.
  Help the supplier complete registration. If asked to fill a field, return
  `{action:'fill', field, value}`; else answer briefly."

See `edge-functions/` for runnable implementations.
