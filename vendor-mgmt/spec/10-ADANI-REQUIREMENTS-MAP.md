# 10. Adani requirements → feature map (from the meeting transcripts)

Source: the 4 Adani meeting transcripts/notes (2026-05-27 consultation + deep-dive,
2026-05-28 NDA/Ariba-integration call). Adani's CPO/architecture team (Chintan =
SAP/MDG/Ariba architect) made the priorities explicit. **Vendor onboarding + vendor
risk analysis is the wedge** ("vendor risk analysis is the key for them"); they want
to "start low — 2–3 categories, 2–3 transactions" then scale across ~500 locations.

## 10.1 Requirement → where it's built

| # | Adani need (verbatim intent) | In our module | Spec location | Pri |
|---|------------------------------|---------------|---------------|-----|
| 1 | Cut **vendor onboarding cycle ≥70%** (baseline ~90 days → days) | AI extraction + autosave wizard + parallel DD + auto-checklist | `05-SCREENS §6.6`, `06-AI…` | P0 |
| 2 | **Vendor risk analysis / due diligence** is the priority | DD checklist (30–40 configurable checks) + risk screening + scorecard gate | `06-AI… §7a.3-4`, this doc §10.2 | P0/P1 |
| 3 | Replace **email-based blocking/blacklisting** with a systematic, auditable workflow | Block/Unblock via `vendor_transition` + audit + sanctions/debarment check | `04-STATE-MACHINE`, `03-RBAC` | P1 |
| 4 | **OFAC, D&B (DNB), Equifax** credit/financial checks | DD providers in `due-diligence` edge fn (mock+live) | `06-AI…`, `09` | P1 |
| 5 | **Direct GST / MSME portal + PAN** verification | DD check `gst_msme` + tax-reg verify; extraction prefills GSTIN | `06-AI…` | P1 |
| 6 | Plug into **3rd-party VDD platform (ProcessUnity)** & bring score in | DD provider adapter `processunity` (API) → DD item | `06-AI…`, `09` | P2 |
| 7 | **Human due-diligence "recording UI"** for manual/physical checks | DD item with `source='human'` + evidence upload | `05-SCREENS §6.3c-DD` | P1 |
| 8 | **Risk-tier-driven DD stringency** (vendor in critical category → deeper DD before approval) | DD checklist filtered by `risk_level`/`tier`; gate enforces | `06-AI… §7a.4` | P1 |
| 9 | **OEM vs dealer/distributor** + **preferred-vendor** tagging (SKF/Schaeffler/NSK) | `vendors.vendor_class`, `is_preferred`, `brand_tags`, OEM→dealer link; AI-assisted tagging | `09 §9.3`, `0007` | P1 |
| 10 | Help **create the preferred/OEM tag where MDG lacks it** (AI) | `vendor-classify` AI suggestion → writes tags → sync to MDG | `06-AI…`, `09` | P2 |
| 11 | **Front-end-configurable SAP/Ariba/MDG/Oracle/Baan integration** ("like Salesforce setup") | Integration wizard + `erp-sync` | `09 §9.2-9.4` | P1 |
| 12 | **Bi-directional vendor-master sync**; push onboarded vendors into SAP/Ariba | `erp-sync` pull/push + `vendor_external_refs` | `09 §9.1,9.5` | P1 |
| 13 | **GRN integration** for objective performance (OTD, quality) | `erp-sync` GRN pull → `vendor_grn_metrics` → scorecard lines | `09 §9.4`, `06` | P1 |
| 14 | **Upload a vendor's Excel/form → AI fills the onboarding form** | `extract-document` extended to xlsx/csv (+ PDF/image) | `06-AI… §7a.2` | P1 |
| 15 | Buyer self-fill **or** vendor self-fill **or** buyer uploads vendor's file | 3 onboarding entry modes already in wizard + portal | `05-SCREENS §6.4-6.6` | P0 |
| 16 | **Multilingual (Hindi / Gujarati)** for business users + assistant | i18n on portal/wizard + `vendor-assistant` language param + voice | `06-AI…`, `11 §11.5` | P1 |
| 17 | **Master-data dedup / rationalization** (MDL chaos, multiple codes/item; 70–80% OOB) | `vendor-dedupe` AI matching → `vendor_duplicate_candidates` review UI | `09`, `0007`, `11` | P2 |
| 18 | **AI web-insights dossier** (financial, news+sentiment, compliance, sanctions, ratings, category/cost intelligence) | Web Insights tab (already specced, expanded) | `05-SCREENS §6.3d`, `06` | P1 |
| 19 | **Vendor enrichment for unknown/local vendors** ("put a local vendor, enrich via internet / managed research") | `vendor-web-insights` + a manual "request research" task | `06-AI…` | P2 |
| 20 | **Customer SMTP** for vendor emails (send from Adani domain) | `send-vendor-notification` honours `NOTIFY_SMTP_*` per org | `07-REALTIME…` | P2 |
| 21 | **Multiple simultaneous sessions / multi-window** | stateless React + Supabase; no single-session lock | `11 §11.2` | P0 |
| 22 | **Mobile**: initiate onboarding, approvals, monitoring | responsive routes + approval actions on mobile | `11 §11.5` | P2 |
| 23 | **BYOC / data residency** (AWS/Azure, region choice) | Supabase project region + self-host note | `11 §11.4` | note |
| 24 | **SOC1/SOC2/GDPR** posture | RLS, audit, encryption, signed URLs, Vault | `11 §11.4` | note |
| 25 | **Per-vendor DD cost < $0.50** | DD = cheap "poll data" model calls (gpt-4o-mini / haiku); cost note | `06-AI…`, `11 §11.6` | note |

## 10.2 Due-diligence checklist (configurable; the "30–40 checks" Adani referenced)

Seeded `due_diligence_checks` (config) — buyer toggles which apply, and can scope by
risk tier. Per-vendor results land in `vendor_due_diligence_items`.

| check_key | category | provider (live) | mandatory | source |
|-----------|----------|-----------------|-----------|--------|
| pan_verify | identity | NSDL/Income-Tax | yes | api |
| gst_active | tax | GST portal | yes | api |
| msme_status | tax | Udyam/MSME portal | no | api |
| sanctions_ofac | sanctions | OFAC (OpenSanctions) | yes | api |
| sanctions_un_eu | sanctions | UN/EU lists | yes | api |
| pep_screen | sanctions | OpenSanctions PEP | yes | api |
| debarment_check | compliance | sectoral debarment lists | no | api |
| credit_dnb | financial | Dun & Bradstreet | no | api |
| credit_equifax | financial | Equifax | no | api |
| litigation_scan | legal | court/news AI scan | no | ai |
| adverse_media | reputation | news + AI | no | ai |
| financial_health | financial | filings + AI | no | ai |
| site_verification | physical | **human recording UI** | conditional | human |
| reference_check | operational | **human recording UI** | no | human |
| processunity_score | aggregate | ProcessUnity API | no | api |

**Gate:** `vendor_transition(...,'approved')` is blocked until all **mandatory** checks
for the vendor's risk tier are `pass` (or explicitly waived with a note on
`vendor_approvals`). DD pass writes `vendor_approvals.due_diligence_passed=true`.

## 10.3 Adani pilot plan (what to actually demo/ship first)

1. **Phase 0 (this build):** Vendor onboarding + DD + risk dossier + SAP/Ariba sync,
   running on the Adani tenant with seeded believable suppliers. Demo per `02-DEMO-SCRIPT.md`
   + the Adani addendum.
2. **Phase 1 pilot (60–90 days):** one BU / 2–3 categories; connect one SAP/Ariba sandbox;
   import existing vendor master; run live onboarding + DD on real suppliers; measure
   **cycle-time reduction** (target ≥70%) and **DD cost/vendor** (target <$0.50).
3. **Phase 2:** scale categories + locations; enable MDG write-back + master-data dedup;
   add Gujarati UI for business users.

## 10.4 Explicitly OUT of vendor-management scope (set expectations)
- **Catalog / L2 punch-out aggregation** — Adani wants Ariba to keep this; AirChain is a platform, not an aggregator (clarified in the meeting). Not in this module.
- **Autonomous sourcing / negotiation / auctions** — separate AirChain module; this spec is vendor management + DD only.
- **Contract redlining/track-changes** — known platform gap; contract *generation* from PO/award is possible but not part of this module.
- **Full project BOQ should-costing** (5.5 km conveyor) — sourcing/spend-insights capability; the vendor 360 only links "category & cost intelligence", not full estimation.
