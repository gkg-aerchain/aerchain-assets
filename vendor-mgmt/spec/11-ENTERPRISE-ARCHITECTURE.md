# 11. Enterprise architecture — performance, scale, security, AI-native

Adani runs ~500 locations, 30–35k potential users (~15k intake users), 14+ SAP
instances, and "people waiting for you to fail." This module must be enterprise-grade
on the Lovable/Supabase stack. This section is how it runs well at scale.

## 11.1 Performance (do these — they're cheap wins)
- **Server-side everything for lists:** the `/vendors` table queries are paginated
  (`range()`), filtered, and sorted in Postgres — never fetch-all-then-filter. Indexes
  in `0001` cover `(org_id, lifecycle_status)`, `pan`, expiry.
- **KPI counts via a view / RPC**, not N client queries: add a `vendor_portfolio_kpis(org_id)`
  RPC returning counts by status/risk/tier + expiring-doc count in one round trip.
- **Analytics via materialized views** refreshed by pg_cron (`mv_vendor_spend`,
  `mv_category_spend`) so Business-Overview charts don't aggregate POs on every load.
- **React Query** for caching + background refetch; **optimistic UI** on mutations.
- **Virtualized tables** (e.g. `@tanstack/react-virtual`) for vendor lists in the thousands.
- **Debounced autosave** (per wizard step) to avoid write storms.
- **Selective realtime:** subscribe with row filters (`vendor_id=eq.…`), not whole tables;
  unsubscribe on unmount. Heavy lists poll-on-focus as a fallback, not a constant socket.
- **Edge functions** do AI/ERP work off the request path; the UI shows progress via
  realtime on `*_sync_runs` / `vendor_risk_screenings` rather than blocking.

## 11.2 Scale & multi-tenant
- **RLS is the tenant boundary** (org_id + role); every table enabled (0001/0004).
- **Multi-window / multi-session**: stateless React + Supabase JWT — no server session
  lock; the same user can run many concurrent windows (explicitly required by Adani).
- **Connection pooling** via Supabase **Supavisor** (transaction mode) for many users.
- **Partition or archive** high-volume `vendor_audit_log` / `integration_sync_records`
  by month at scale (note; not needed for the pilot).
- **Batch ERP sync** with paging + resumable runs (`integration_sync_runs`).

## 11.3 AI-native design (knowledge-hub aligned)
- All AI server-side, provider-agnostic (`_shared/ai.ts`), OpenAI default, Gemini/Claude
  fallback — matches Adani's "20–30 sonnet/4o calls, <$0.50/vendor" DD economics.
- **Cheap model for polling/DD** (`gpt-4o-mini` / `claude-haiku` / `gemini-flash`),
  **vision model for extraction** (`gpt-4o`), so cost stays low.
- **Knowledge capture:** every extraction, screening, evaluation, and ERP payload is
  persisted (`extracted_data`, `result` jsonb, `vendor_web_insights`) — the system gets
  smarter and auditable, mirroring AirChain's "knowledge bank" pitch.
- **Atlas assistant** (`vendor-assistant`) is the conversational layer over onboarding;
  voice + multilingual; can fill fields (`action:'fill'`).

## 11.4 Security & compliance (SOC1/SOC2/GDPR posture)
- RLS on every table; PII (bank a/c) masked except for authorized roles (`03-RBAC`).
- **Secrets in Supabase Vault / edge-function secrets** — no keys in client or DB columns;
  ERP credentials in Vault (`09`).
- **Signed URLs** for all document access (expiring); private Storage bucket.
- **Full audit** (`vendor_audit_log`) on every state change, DD action, doc verify, ERP sync.
- **Encryption at rest** (Supabase/Postgres) + TLS in transit.
- **BYOC / data residency:** deploy the Supabase project in the required region; for
  strict BYOC, self-host Supabase in the customer's AWS/Azure tenant (Adani asked about
  data egress + region — answerable: region-pinned, no egress beyond chosen AI provider,
  which can be Azure-hosted OpenAI for residency). `[A8]`

## 11.5 Localization & mobile
- **i18n** (e.g. `react-i18next`) on the Adani portal + onboarding wizard; locale switch
  EN / हिन्दी / ગુજરાતી. `vendor-assistant` takes a `language` param and replies in-language
  (Atlas spoke Gujarati in the demo).
- **Responsive** routes; mobile supports **initiate onboarding, approvals, monitoring,
  notifications** (per Adani's stated mobile expectation) — not full wizard authoring.

## 11.6 Cost control
- DD/screening uses the cheapest capable model + caches results (`vendor_risk_screenings`,
  `vendor_web_insights`) so repeat views don't re-bill.
- `RISK_MODE=mock` / `INTEGRATION_MODE=mock` for demos = zero external spend.
- Materialized views + indexes keep DB compute low under heavy read.

## 11.7 Observability
- `integration_sync_runs` / `_records`, `vendor_risk_screenings`, `vendor_audit_log` give
  end-to-end traceability. Edge functions log structured errors. Degraded AI/ERP calls
  return `{degraded:true}` so the UI shows a graceful state, never a hard crash.
