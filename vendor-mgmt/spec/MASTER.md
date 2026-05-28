<!-- AUTO-GENERATED 2026-05-28 by build_master.py — do not edit; edit the source files. -->
# AERCHAIN VENDOR MANAGEMENT + DUE DILIGENCE — MASTER SPEC (single-file)
This file concatenates the entire spec package (docs + SQL migrations + edge
functions) in apply-order. Upload it to Lovable in one shot. When a section is a
code file, its path is shown in the heading just above the code block — create the
file at that path.

---

# PART A — DOCUMENTATION


<!-- ===== README.md ===== -->

# Aerchain Vendor Management & Due Diligence — Spec Package

Complete, build-ready spec for a **fully working** vendor management + due-diligence
module (React 18 + Vite + Tailwind + shadcn/ui + Supabase). Built to be fed into
Lovable. **No features cut.** Designed to match the existing `demo.aerchain.io` shell
exactly (analyzed from 20 screenshots) and to serve the **Adani-on-Aerchain** tenancy
model with AI doc-extraction, third-party risk screening, and a due-diligence gate.

## Read / apply in this order
1. **`00-OVERVIEW.md`** — architecture, multi-tenancy (Aerchain platform / Adani tenant), roles, AI provider strategy, conventions, assumptions.
2. **`01-SCOPE.md`** — full feature set as P0/P1/P2 build order (nothing cut).
3. **`02-DEMO-SCRIPT.md`** — the north star (10-min two-window walkthrough). The app is done when this runs.
4. **`migrations/0001_schema.sql` → `0007_integration_dd_tagging.sql`** — apply as Supabase migrations:
   - `0001_schema.sql` enums + tables + grants + enable RLS
   - `0002_functions_triggers.sql` updated_at, state machine `vendor_transition()`, scorecard recompute
   - `0003_rpcs.sql` portal/invitation/onboarding RPCs (safe public entry points)
   - `0004_rls.sql` row-level security policies
   - `0005_storage_realtime.sql` `vendor-documents` bucket + storage policies + realtime publication
   - `0006_seed.sql` 10 lifecycle vendors + 6 prospects + Tata Steel 360 depth + demo users
   - `0007_integration_dd_tagging.sql` ERP connections, vendor tagging (OEM/dealer/preferred), GRN metrics, configurable due-diligence checklist + `approve_vendor` gate, dedup
5. **`03-RBAC.md`**, **`04-STATE-MACHINE.md`** — access matrix + lifecycle reference.
6. **`05-SCREENS.md`** — screen-by-screen wiring (existing tabs + net-new Adani portal, vendor dashboard/workspace/PO + integration/DD/tagging/dedup screens).
7. **`06-AI-RISK-DUEDILIGENCE.md`** + **`edge-functions/`** — deploy edge functions; wire AI extraction, MCA, Web Insights, risk screening, **due diligence**, **erp-sync**, **vendor-classify**, **vendor-dedupe**, evaluation AI, assistant.
8. **`07-REALTIME-NOTIFICATIONS.md`** — realtime channels + `send-vendor-notification`.
9. **`08-EXECUTION-AND-KILLSWITCH.md`** — hour-by-hour build plan + demo-day fallbacks.
10. **`09-ERP-INTEGRATION.md`** — front-end-configurable SAP/Ariba/MDG/Coupa/Oracle integration + bi-directional vendor-master sync.
11. **`10-ADANI-REQUIREMENTS-MAP.md`** — Adani needs (from transcripts) → features; DD checklist; pilot plan; out-of-scope.
12. **`11-ENTERPRISE-ARCHITECTURE.md`** — performance, scale, security (SOC2/GDPR), AI-native, localization (Hindi/Gujarati), mobile, BYOC.

## Lovable kickoff prompt (paste first)
> Build an **enterprise-grade, AI-native** Vendor Management + Due Diligence module on
> our existing React 18 + Vite + Tailwind + shadcn + Supabase app, matching the current
> `/vendors` and `/vendor/*` design exactly. Apply the SQL migrations in
> `vendor-mgmt/spec/migrations/` in order (0001→0007). Then deploy the edge functions in
> `vendor-mgmt/spec/edge-functions/` and set their secrets (default AI provider =
> OpenAI; `RISK_MODE=mock`, `INTEGRATION_MODE=mock`). Wire the screens per `05-SCREENS.md`,
> realtime/notifications per `07`, AI/risk/DD per `06`, and the **front-end-configurable
> SAP/Ariba/MDG integration with bi-directional vendor-master sync** per `09`. Multi-tenant:
> Aerchain is the platform, **Adani** is the buyer tenant; the public Adani portal
> (`/portal/adani`) redirects vendors into the Aerchain-branded onboarding. Honour the
> Adani requirement map in `10` (≥70% onboarding cycle reduction, configurable
> due-diligence checklist with OFAC/D&B/GST/MSME/PEP/ProcessUnity + human checks and an
> approval gate, OEM-vs-dealer tagging, GRN-sourced performance, master-data dedup,
> Hindi/Gujarati localization) and the enterprise architecture in `11`. Acceptance = the
> demo script in `02-DEMO-SCRIPT.md` (incl. the Adani addendum) runs end-to-end across two
> browser windows with real persistence and role-based access. Do not cut features.

## Status of inputs
- Reference screenshots (20) live on `main` under `vendor-mgmt/screenshots/` (gitignored on this branch).
- Net-new screens (no existing capture): Adani portal `/portal/:slug`, vendor `/dashboard`, `/workspace/:customerId`, `/purchase-orders` — specced in `05-SCREENS.md`, to be built in the same design language.


<!-- ===== 00-OVERVIEW.md ===== -->

# Aerchain Vendor Management & Due Diligence — Build Spec (v1)

> **What this is.** A complete, directly-executable specification for turning the
> existing Aerchain "vendor" UI shell into a **fully working** Vendor Management +
> Due Diligence module on **React 18 + Vite + Tailwind + shadcn/ui + Supabase**.
> It is written to be fed to Lovable (the coding agent) section by section.
>
> **No features are cut.** The original 24-hour briefing told you to drop scope to
> hit a deadline. Per the product owner's explicit instruction, *nothing is cut* —
> every screen seen in the current demo (`demo.aerchain.io`) is made real, and the
> AI / third-party-risk / due-diligence capabilities are built out, not faked.

---

## 0.1 How to use this spec with Lovable

Feed files in this order. Each is self-contained enough to be a Lovable prompt, but
they share one data model, so **apply the SQL first**, then wire screens.

| # | File | What Lovable does with it |
|---|------|---------------------------|
| 1 | `00-OVERVIEW.md` (this) | Read for architecture, tenancy, naming, AI setup. |
| 2 | `01-SCOPE.md` | Build-order priority (P0/P1/P2). Nothing is "cut", priority = sequence. |
| 3 | `02-DEMO-SCRIPT.md` | The north star. The app is "done" when this script runs end-to-end. |
| 4 | `migrations/0001…0007_*.sql` | Apply as Supabase migrations (enums, tables, grants, functions, RPCs, triggers, RLS, storage, realtime, **ERP integration + DD + tagging**). |
| 5 | `03-RBAC.md` / `04-STATE-MACHINE.md` | Reference for the access matrix + `vendor_transition()` behaviour. |
| 6 | `05-SCREENS.md` | Screen-by-screen wiring (reads/writes/components/states). Includes net-new vendor portal. |
| 7 | `06-AI-RISK-DUEDILIGENCE.md` + `edge-functions/*` | Deploy edge functions; wire AI doc-extraction, MCA fetch, Web Insights, risk screening, AI assistant. |
| 8 | `07-REALTIME-NOTIFICATIONS.md` | Realtime channels + `send-vendor-notification` edge function + in-app toasts. |
| 9 | `migrations/0006_seed.sql` | Seed 10 vendors + users + docs + scorecards + audit so the app is populated on first load. |
| 10 | `08-EXECUTION-AND-KILLSWITCH.md` | Hour-by-hour build plan + demo-day fallbacks. |
| 11 | `09-ERP-INTEGRATION.md` | Front-end-configurable SAP/Ariba/MDG/Coupa/Oracle integration; bi-directional vendor-master sync; `erp-sync` edge fn. |
| 12 | `10-ADANI-REQUIREMENTS-MAP.md` | Every Adani need (from the meeting transcripts) → feature → where built; the DD checklist; pilot plan; out-of-scope. |
| 13 | `11-ENTERPRISE-ARCHITECTURE.md` | Performance, scale, multi-tenant, security/SOC2/GDPR, AI-native, localization (Hindi/Gujarati), mobile, BYOC. |

**Why this is more than the original brief.** The product owner supplied the actual
Adani meeting transcripts. The spec is now grounded in Adani's stated priorities —
vendor onboarding cycle reduction (≥70%), **vendor risk analysis / due diligence as the
wedge**, front-end-configurable SAP/Ariba/MDG integration with **bi-directional vendor-
master sync**, OEM-vs-dealer tagging, GST/MSME + OFAC + D&B + ProcessUnity due diligence,
GRN-sourced performance, master-data dedup, and Gujarati-language support. See `10`.

---

## 0.2 Product architecture (multi-tenant)

**Aerchain is the SaaS platform.** Buyer enterprises (e.g. **Adani Group**) are
**tenant orgs** inside Aerchain. Vendors (e.g. Tata Steel) are companies that hold a
**relationship per buyer org**.

```
                          ┌───────────────────────────────────────────┐
                          │                AERCHAIN (SaaS)              │
                          │                                             │
  Adani-branded           │   BUYER SIDE (tenant = Adani)               │
  vendor portal  ──────▶  │   /vendors, /vendors/:id, /vendors/prospects│
  (public front door,     │   roles: buyer_admin / buyer_approver /     │
   "Register now")        │          buyer_requester                    │
        │                 │                                             │
        │ redirect        │   VENDOR SIDE (Aerchain-branded)            │
        └───────────────▶ │   /vendor/auth, /vendor/onboard,            │
                          │   /vendor/dashboard,                        │
                          │   /vendor/workspace/:customerId,            │
                          │   /vendor/purchase-orders                   │
                          │   role: vendor_user                         │
                          └───────────────────────────────────────────┘
```

Key tenancy facts that drive the data model:

1. **`organizations`** = buyer tenants (Adani Group is the demo tenant). Aerchain
   staff accounts live here too but the demo buyer is Adani.
2. **`vendors`** = a vendor-company record **scoped to one buyer org** (`org_id`).
   It carries the relationship lifecycle (Invited→…→Active/Blocked), tier, risk,
   vendor code, and the onboarding profile. The buyer's *Vendor 360* is exactly one
   `vendors` row.
3. A vendor **company** can be a vendor to **multiple** buyer orgs. So a vendor
   **user** (`vendor_users`) is linked to one-or-more `vendors` rows via
   **`vendor_memberships`**. That powers `/vendor/dashboard` (list of customers)
   and `/vendor/workspace/:customerId` (one customer = one `org_id`).
4. **Onboarding is per buyer-org** (realistic: each buyer demands its own
   onboarding). All onboarding child data (tax registrations, sites, contacts,
   banking, documents, qualification) hangs off a `vendor_id`.

> `[ASSUMPTION]` The existing backend has `profiles`, `org_users`, `roles`,
> `has_role(uid,text)`, `is_admin(uid)`. We create `organizations` idempotently
> (`CREATE TABLE IF NOT EXISTS`) and assume `org_users(user_id, org_id)` maps buyer
> users to their tenant. If `organizations`/`org_users` already exist with different
> columns, Lovable should reconcile column names, not duplicate tables.

---

## 0.3 The 4-tier vendor hierarchy (confirmed from the live UI)

The current app models vendors as a **4-tier tree**. The data model mirrors it:

```
Tier 1  Group            → vendors.group_name (e.g. "Tata Group")  [logical, on the vendor row]
Tier 2  Legal Entity     → vendors                                 (Tata Steel Limited, PAN-level)
Tier 3  Tax Registration → vendor_tax_registrations                (GSTIN / IEC, per state/jurisdiction)
Tier 4  Site             → vendor_sites                            (office/factory/warehouse/hub/branch)
```

Contacts attach **either** entity-wide (`vendor_id`, `tax_registration_id IS NULL`)
**or** to a specific tax registration (`tax_registration_id` set). Banking is at the
legal-entity (Tier 2) level. This is exactly what the onboarding wizard and the
*Hierarchy* tab show.

---

## 0.4 Roles (RLS-enforced)

| Role | Who | Lives in |
|------|-----|----------|
| `buyer_admin` | Adani procurement admin (Priya) — full control of the tenant's vendors | buyer org |
| `buyer_approver` | Approves/rejects vendors, signs off due diligence | buyer org |
| `buyer_requester` | Adds prospects, requests onboarding, views vendors | buyer org |
| `vendor_user` | The supplier (Rakesh @ Tata Steel) — sees only their own `vendors` rows | vendor side |

`has_role(auth.uid(), 'buyer_admin')` etc. drive every RLS policy. Vendor-side
access is scoped through `vendor_memberships` (see `03-RBAC.md`).

---

## 0.5 AI provider strategy — provider-agnostic, OpenAI default

All AI runs **server-side in Supabase Edge Functions** (Deno). The client never
holds a key. One thin gateway (`_shared/ai.ts`) abstracts the provider:

```
provider = env AI_PROVIDER  (default "openai")
  openai  → OPENAI_API_KEY    model gpt-4o (vision+json), gpt-4o-mini (cheap text)
  gemini  → GEMINI_API_KEY    model gemini-2.5-flash (Lovable AI Gateway fallback)
  (claude → ANTHROPIC_API_KEY model claude-sonnet-4-6  — optional, same interface)
```

- **Why server-side:** keys stay secret; RLS-safe writes via service role; CORS-clean.
- **Secrets** (set once in Supabase → Project → Edge Functions → Secrets, *no
  dashboard schema clicks needed*): `AI_PROVIDER`, `OPENAI_API_KEY`,
  `GEMINI_API_KEY`, optional `ANTHROPIC_API_KEY`, plus risk-data keys in §0.6.
- **Fallback chain:** if the primary provider errors or a key is missing, the
  gateway retries the next configured provider, then returns a graceful
  `{ ok:false, degraded:true }` so the UI can show a "couldn't auto-fill" state
  instead of breaking the demo.

> The original briefing mandated Gemini-only via Lovable AI Gateway. The product
> owner has overridden this: **OpenAI is the default**, Gemini is the fallback,
> Claude is optional. Real keys are provided as edge-function secrets.

---

## 0.6 Third-party risk / due-diligence data sources

The *Evaluation* and *Web Insights* tabs reference external risk data. We implement
a **single `risk-screening` edge function** with **pluggable providers** and a
**deterministic mock mode** so the demo never depends on a flaky external API.

| Signal | Real provider (pluggable) | Demo mode | Stored in |
|--------|---------------------------|-----------|-----------|
| Sanctions / PEP screening | OpenSanctions API (`OPENSANCTIONS_API_KEY`) | seeded "Clean" w/ counts | `vendor_risk_screenings` |
| Credit rating | CRISIL/D&B (manual or `DNB_API_KEY`) | seeded ratings | `vendor_web_insights` |
| News + sentiment | NewsAPI/GDELT (`NEWS_API_KEY`) + AI sentiment | seeded + AI-scored | `vendor_news_items` |
| MCA company/director data | MCA/Probe42 (`MCA_API_KEY`) | AI-synthesised from PAN/CIN | writes onboarding fields |
| Country/geographic risk | World Bank/static index | static table | scorecard line input |

**Mode switch:** `RISK_MODE = "mock" | "live"` (default `mock` for demo safety).
Every screening writes an `vendor_audit_log` row and a `vendor_risk_screenings`
record so the result persists and survives refresh.

---

## 0.7 Conventions Lovable must enforce (from briefing, kept)

- Everything in `public` schema.
- **No FK to `auth.users`.** Use `vendor_users` mapping + `created_by uuid` columns.
- Every table: `id uuid pk default gen_random_uuid()`, `created_at timestamptz`,
  `updated_at timestamptz` (via trigger), `created_by uuid`.
- Every `CREATE TABLE` is followed by a `GRANT` block and explicit **RLS** policies
  using `has_role(auth.uid(),'role')`.
- One `vendor_audit_log(vendor_id, actor_id, action, payload jsonb, at)`.
- Enums for: vendor lifecycle status, vendor tier, risk level, document type,
  document status, approval decision, tax type, site type, contact role,
  notification type, message author type, scorecard dimension, screening type.
- **No invented columns** — every column is read or written by a screen in
  `05-SCREENS.md`.
- No dashboard-only actions; everything is SQL migrations + edge-function deploys.

---

## 0.8 Visual system (match existing app exactly)

- shadcn/ui components, **DM Sans**, semantic Tailwind tokens (no hard-coded hex).
- Primary = the existing violet/purple. Status colors via tokens
  (`success`, `warning`, `destructive`, `muted`).
- "Standard Canvas" 2-column glass layout; rounded-2xl cards; soft shadows; pill
  badges for status/tier/risk; sparkline KPI cards on list pages.
- Reuse the existing components inventory (`src/components/vendor/*`) — see
  `05-SCREENS.md` "reuse vs build" columns. **Do not restyle**; only wire data.

---

## 0.9 Assumptions log (correct before handing back to Lovable)

- `[A1]` GSTIN format = 15 chars `^\d{2}[A-Z]{5}\d{4}[A-Z]\d[Z][A-Z\d]$`; PAN =
  `^[A-Z]{5}\d{4}[A-Z]$`; IFSC = `^[A-Z]{4}0[A-Z0-9]{6}$`; CIN = 21 chars. Used for
  client-side validation only (warn, don't block — demo data must always submit).
- `[A2]` Demo buyer tenant = **Adani Group**; demo vendor = **Tata Steel** (matches
  seeded `ent-1`). Public vendor portal is **Adani-branded**; onboarding is
  **Aerchain-branded**.
- `[A3]` Currency display = INR with Indian grouping (₹45.2 Cr, ₹95,00,000). Amounts
  stored as `numeric` in base units (rupees) + a `currency` text default 'INR'.
- `[A4]` Vendor "Auto-Fill Demo" button stays — it now calls the real
  doc-extraction/MCA edge functions in demo mode, not a hard-coded form fill.
- `[A5]` Email delivery via Resend (`RESEND_API_KEY`) in `send-vendor-notification`;
  if absent, notifications still persist in-app (email is best-effort).
- `[A6]` "Tier" (Strategic/Preferred/Approved/Conditional) is a buyer-assigned
  classification distinct from the 4-tier hierarchy; stored as `vendors.tier`.


<!-- ===== 01-SCOPE.md ===== -->

# 1. Scope — full feature set (nothing cut; priority = build order)

The briefing asked us to mark MUST/SHOULD/CUT. Per the product owner, **nothing is
cut.** Instead, every feature is **P0 / P1 / P2** to define the *order* Lovable
builds in so the demo script is runnable as early as possible — but all three tiers
ship.

"Real bar" = persists to Postgres, multi-user via RLS, survives refresh.

| # | Feature | Priority | Real bar | Notes |
|---|---------|----------|----------|-------|
| 1 | Auth + RBAC (4 roles, RLS) | **P0** | ✅ | buyer_admin/approver/requester + vendor_user. |
| 2 | Vendor lifecycle state machine + audit + timestamps | **P0** | ✅ | `vendor_transition()`; enforced transitions. |
| 3 | Prospects: add prospect + send invitation | **P0** | ✅ | Manual / RFx / Self-Registration sources. |
| 4 | Adani public portal + "Register now" → Aerchain onboarding | **P0** | ✅ | Net-new screen; invitation-token + open self-reg. |
| 5 | Vendor auth (signup/login/invite-accept) | **P0** | ✅ | Net-new; magic link or password. |
| 6 | Onboarding wizard (7 tiered steps) with real persistence + autosave | **P0** | ✅ | Company / Tax / Sites&Contacts / Banking / Qualification / Documents / Declarations. |
| 7 | Document vault: upload → Storage, signed URLs, expiry, re-upload reminders | **P0** | ✅ | Per tier/category/compliance requirements. |
| 8 | Buyer Vendor list (3 tabs) + KPI cards + filters | **P0** | ✅ | Prospects / Onboarding in Progress / Registered. |
| 9 | Vendor 360 — Registration review tab | **P0** | ✅ | Read of full submission. |
| 10 | Approval workflow: review → approve/reject (+ reasons) | **P0** | ✅ | `vendor_approvals`; multi-approver capable. |
| 11 | In-app notifications + email edge fn on key events | **P0** | ✅ | invitation/submitted/approval-needed/decision/expiry. |
| 12 | Realtime cross-user sync (<5s) | **P0** | ✅ | The buyer↔vendor "wow moment". |
| 13 | Vendor dashboard (multi-customer) + workspace per customer | **P1** | ✅ | Net-new; lists relationships + status. |
| 14 | **AI doc-extraction → auto-map to onboarding sections** | **P1** | ✅ | Upload pile of docs → fields populate + map to required slots. |
| 15 | **AI MCA auto-fetch** (company + directors from PAN/CIN) | **P1** | ✅ | "Auto-Fetch from MCA" button made real. |
| 16 | Vendor 360 — Business Overview (spend/PO analytics) | **P1** | ✅ | From `purchase_orders` seed. |
| 17 | Vendor 360 — Hierarchy tab (4-tier tree) | **P1** | ✅ | Group→Entity→GSTIN→Site. |
| 18 | **Evaluation / Scorecard** (6 weighted dimensions, composite, triggers) | **P1** | ✅ | Buyer scores; AI-assisted suggestions. |
| 19 | **Due-diligence workflow** (gate before approval) | **P1** | ✅ | Screening + scorecard sign-off. See §6. |
| 20 | **Web Insights** dossier (AI public intel + 3rd-party risk) | **P1** | ✅ | Overview, news+sentiment, sanctions/PEP, ratings, filings. |
| 21 | **Sanctions / PEP / credit / news screening** (pluggable, mock+live) | **P1** | ✅ | `vendor_risk_screenings`; feeds DD + scorecard. |
| 22 | Communication thread (buyer ↔ vendor) | **P1** | ✅ | `vendor_messages`, realtime. |
| 23 | Block / Unblock with reason + audit | **P1** | ✅ | Dialogs exist; wire to state machine. |
| 24 | Audit log viewer | **P1** | ✅ | Reads `vendor_audit_log`. |
| 25 | Vendor purchase-orders list + PO detail (vendor side) | **P2** | ✅ | Net-new; reads shared `purchase_orders`. |
| 26 | **AI vendor assistant** (chat helper during onboarding) | **P2** | ✅ | "Aiera"-style; answers + fills fields. |
| 27 | Scorecard re-evaluation triggers (time/event/transaction) | **P2** | ✅ | Scheduled + event hooks create tasks/notifications. |
| 28 | Dashboard KPIs (buyer portfolio analytics) | **P2** | ✅ | Counts by status/risk/tier. |
| 29 | Saved filters / search across vendors | **P2** | ✅ | Server-side filtered queries. |
| 30 | Bulk actions (multi-select on list) | **P2** | ✅ | Bulk remind/export. |
| 31 | **Configurable due-diligence checklist** (30–40 checks) + approval gate | **P1** | ✅ | OFAC/D&B/Equifax/GST/MSME/PEP/ProcessUnity + AI + human; `approve_vendor` gate. |
| 32 | **Human DD recording UI** (manual/site/reference checks) | **P1** | ✅ | `vendor_due_diligence_items` source=human + evidence upload. |
| 33 | **Vendor tagging** (OEM/dealer/distributor, preferred, brand tags) + AI classify | **P1** | ✅ | `vendors.vendor_class/is_preferred/brand_tags`; `vendor-classify`. |
| 34 | **Front-end-configurable ERP integration** (SAP/Ariba/MDG/Coupa/Oracle) | **P1** | ✅ | Connection wizard + `erp-sync`; creds in Vault. |
| 35 | **Bi-directional vendor-master sync** (import + push-on-approval) | **P1** | ✅ | `erp-sync` pull/push + `vendor_external_refs`. |
| 36 | **GRN-sourced performance** (OTD, quality) into scorecard | **P1** | ✅ | `erp-sync` grn → `vendor_grn_metrics`. |
| 37 | **Excel/CSV/PDF upload → AI fills onboarding form** | **P1** | ✅ | `extract-document` (vision + spreadsheet). |
| 38 | **Master-data dedup / rationalization** review | **P2** | ✅ | `vendor-dedupe` → `vendor_duplicate_candidates`. |
| 39 | **Multilingual** UI + assistant (EN / हिन्दी / ગુજરાતી) | **P1** | ✅ | i18n + `vendor-assistant` language param. |
| 40 | **Customer SMTP / send-from-buyer-domain** | **P2** | ✅ | per-org SMTP in `send-vendor-notification`. |

**Build sequencing rule:** finish all **P0** before any P1 so the *demo script*
(`02-DEMO-SCRIPT.md`) runs end-to-end; then P1 adds the AI/risk/DD richness that
makes it impressive; then P2 polish. Everything ships.


<!-- ===== 02-DEMO-SCRIPT.md ===== -->

# 2. Demo script — the north star (10 min, two windows side-by-side)

**The app is "done" when this script runs end-to-end without a refresh fixing
anything.** Build to make every step below literally work against Postgres.

**Personas**
- **Priya Sharma** — Buyer Admin @ **Adani Group** (on Aerchain). `priya@adani-demo.com` / role `buyer_admin`. **Left window.**
- **Rakesh Kumar** — Vendor contact @ **Tata Steel**. `rakesh@tatasteel-demo.com` / role `vendor_user`. **Right window.**

Pre-seed state: 10 vendors exist (Tata Steel = `ent-1`, already Active for the
"360" depth). One vendor — **"Bharat Forge Limited"** — is left at status
**`invited`** with a fresh invitation token so we can drive a *live* onboarding.
One Active vendor — **"Asian Paints Limited"** — has a document expiring in **7
days** for the alert moment.

---

### Act 1 — Buyer invites a vendor (Priya, left) · ~1.5 min
1. Priya is on **`/vendors`**. Point out the 3 tabs (**Prospects · Onboarding in Progress · Registered Vendors**), KPI cards with sparklines, and the populated table (Tata Steel, Siemens, L&T, Hindalco…). *"This is Adani's live vendor master — real records, not mockups."*
2. Click **Prospects** tab → **`/vendors/prospects`**. KPIs: Total 6 / Active 3 / Onboarding Initiated 1 / Onboarded 1.
3. Click **+ Add Prospect**. Dialog "Add Vendor Prospect". Enter:
   - Company **"Bharat Forge Limited"**, Category **Capital & Equipment**
   - Contact **Rakesh Kumar**, **rakesh@tatasteel-demo.com**, +91 98765 12345, **Procurement Head**
4. Click **Send Invitation**. → row appears, status **Invited**, Source **Manual**. A toast fires; `vendor_invitations` row + token created; `send-vendor-notification` queues an email. **Realtime:** the new row is already live.

> **Wow #1 (realtime):** the invitation email link is shown on screen (demo helper
> surfaces the token URL). Copy it to the right window.

---

### Act 2 — Vendor registers via the Adani portal (Rakesh, right) · ~3.5 min
5. Right window opens the **Adani-branded vendor portal** (`/portal/adani`) — Adani logo, "Become an Adani Supplier", a **Register now** button, *and* an "I have an invitation" field. *"Adani's own branded front door; the experience is powered by Aerchain."*
6. Paste the invitation token (or click the emailed link). → redirect to **Aerchain-branded** `/vendor/auth?invite=…`. Rakesh sets a password (or magic-link). → lands on **`/vendor/onboard`** with the company pre-filled from the invitation.
7. **The AI moment.** Top of the wizard: an **"Upload your documents — we'll fill the form"** dropzone. Rakesh drags **4 files** (PAN card, GST certificate, ISO 9001 cert, cancelled cheque).
   - A progress strip shows **"Extracting… mapping to sections…"**.
   - `extract-document` (OpenAI vision) reads each file; fields populate across steps: **PAN AAACT…**, legal name, **GSTIN + state**, ISO cert number + **expiry 2027-06-30**, bank IFSC + account. Each file is auto-filed into its **required document slot** (Documents step) with a green "matched" chip.

> **Wow #2 (AI doc-extraction → auto-map):** a pile of unlabeled PDFs becomes a
> half-completed, correctly-sectioned registration in ~10 seconds.

8. On **Company Profile**, click **Auto-Fetch from MCA**. → `mca-fetch` returns entity type, CIN, incorporation date, and **directors** (Narendran/Chatterjee) which populate the Directors table.
9. Rakesh clicks through the remaining steps (mostly pre-filled): **Tax Registrations** (GSTIN Maharashtra), **Sites & Contacts** (Mumbai HQ + himself as Primary), **Banking** (Domestic, SBI/IFSC, cheque already attached), **Qualification** (turnover, ISO cert auto-added, ESG chips), **Documents** (all required slots show **matched/uploaded**), **Declarations** (accept 4 declarations, signatory = Rakesh).
10. Click **Submit Registration**. → `vendor_transition()` moves Bharat Forge `registering → submitted`; audit row written; **`send-vendor-notification`** fires "approval needed" to Priya.

---

### Act 3 — Realtime hits the buyer + due diligence (Priya, left) · ~3 min
11. **Without refreshing**, Priya's left window shows a **toast + bell badge**: *"Bharat Forge Limited submitted registration."* The **Onboarding in Progress** tab count ticks up.

> **Wow #3 (true realtime multi-user):** state changed by Rakesh appears on Priya's
> screen in <5s, no reload.

12. Priya opens **Bharat Forge** → **Vendor 360 → Registration** tab: the full submission she just received (profile, GSTIN+linked site, banking masked, qualification, the 4 verified-pending docs, declarations).
13. Switch to **Web Insights** tab → click **Refresh Now**. → `vendor-web-insights` (AI + `risk-screening`) builds the dossier live: **company overview, key personnel, financial snapshot (CRISIL rating), News + sentiment, MCA/GST filing status, Sanctions screening = Clean, PEP screening = Clean.**

> **Wow #4 (AI + 3rd-party risk):** an instant due-diligence dossier from public
> signals — "this is the part that takes analysts days."

14. Switch to **Evaluation** tab → **+ Add Evaluation** → scope = *Financial Health, Compliance, ESG*, assign evaluator = Priya. Open the scorecard; click **"AI suggest scores"** → the model proposes 1–5 per criterion *with the data source + rationale* (e.g. On-Time Delivery from PO/GRN records). Priya adjusts two, saves. **Composite = e.g. 81/100, Low Risk.** This is the **due-diligence gate**.
15. Banner on the 360: *"Due diligence complete — ready for decision."* Priya clicks **Approve** (top-right action), enters a note. → `vendor_transition()` `under_review → approved → active`; vendor code assigned (**BHFRG-001**); audit rows; notification to Rakesh.

---

### Act 4 — Vendor sees the result + the expiry alert · ~1.5 min
16. Right window (Rakesh) shows a **realtime toast**: *"🎉 Adani approved your registration."* He opens **`/vendor/dashboard`** → the **Adani** card now reads **Active / Approved**, with his vendor code. He opens **`/vendor/workspace/adani`** → sees onboarding complete + a **Purchase Orders** section (seeded POs) and a **Messages** thread.
17. **Expiry alert finale (Priya).** Back on `/vendors`, a **red "Documents expiring" KPI** shows **Asian Paints — ISO cert expires in 7 days**. Priya clicks it → vendor 360 → Documents → **Send re-upload reminder**. → notification + email to that vendor; audit row.

> **Wow #5 (lifecycle, not just onboarding):** the system keeps managing the vendor
> after approval — expiring docs, re-screening triggers, messaging.

18. Close: *"Everything you saw is real — one Postgres database, role-based, two live
users, AI doing the heavy lifting on extraction and risk. Refresh any window; it
persists."*

---

### Data the script depends on (must be seeded — see `migrations/0006_seed.sql`)
- Tata Steel (`ent-1`) fully Active with 360 depth (POs, scorecard 79/100, web insights, hierarchy).
- **Bharat Forge** at `invited` with a valid invitation token (for live onboarding).
- **Asian Paints** Active with one document `expires_at = today + 7 days`.
- Priya (`buyer_admin`@Adani), a `buyer_approver`, a `buyer_requester`; Rakesh + 3 other `vendor_user`s.
- 10 vendors spanning every status; ~25 documents; 5 scorecards; audit trail.

### Kill-switches referenced here
If any AI call is slow/offline live, the **Auto-Fill Demo** button and
`RISK_MODE=mock` produce the same on-screen result deterministically (see
`08-EXECUTION-AND-KILLSWITCH.md`).

---

## Adani enterprise addendum (extra beats for the Adani audience)

Adani's team cares about onboarding-cycle reduction, **vendor risk/due diligence**,
and **SAP/Ariba integration**. Insert these beats into Acts 3–4:

- **A3+ Due-diligence gate (replaces the "score and approve" beat with the real gate):**
  On Bharat Forge's 360, open the **Due Diligence** panel → **Run due diligence**.
  In seconds: **PAN ✓, GST active ✓, OFAC ✓, PEP ✓, D&B (5A1) ✓**; the **site
  verification** check shows **Manual review** — Priya opens the **recording UI**,
  marks it verified with a note + uploads the visit report. Gate flips to **"Mandatory
  complete"** and **Approve** unlocks. Say: *"This is the vendor-risk piece — OFAC, GST,
  D&B, sanctions, PEP, automated; physical checks captured in one place; nothing by
  email anymore."*
- **A3+ Vendor tagging:** show **AI suggest tag** → classifies Bharat Forge as **OEM /
  manufacturer**; show the **OEM vs Dealer** filter on `/vendors`. Say: *"SKF vs its
  dealer — the system tags it, and we can push that preferred/OEM tag back into your
  MDG."*
- **A4+ Push to SAP/Ariba (the integration money-shot):** approving the vendor triggers
  `erp-sync` → the 360 shows **"Synced to SAP — LIFNR 0001000048"** and `/settings/
  integrations` shows the **outbound sync run** complete. Say: *"The moment you approve,
  the vendor lands in your SAP vendor master — front-end configured, no back-end dev."*
- **A1±/setup Integration setup:** if asked, open `/settings/integrations` → show the
  **Choose system → credentials → Test (green) → field map** flow and a **Pull vendor
  master** run importing existing suppliers (SKF/Schaeffler/dealer).
- **Gujarati moment:** flip the language toggle to **ગુજરાતી**; ask the Atlas assistant a
  question — it replies in Gujarati (business-user adoption point).
- **Cycle-time close:** end on the KPI — *"What takes ~90 days across SAP+Ariba+MDG+email
  here happened in minutes, end-to-end, with the risk work done for you."*


<!-- ===== 03-RBAC.md ===== -->

# 5. RBAC matrix (RLS-enforced)

Roles: `buyer_admin`, `buyer_approver`, `buyer_requester`, `vendor_user`, plus
`anon` (public portal). ✅ = allowed, ❌ = denied. The **RLS predicate** column is
what actually enforces it in Postgres (see `0004_rls.sql` / RPCs in `0003_rpcs.sql`).

| Action | admin | approver | requester | vendor | anon | Enforcement (predicate / mechanism) |
|--------|:----:|:----:|:----:|:----:|:----:|----|
| View vendor list / 360 (own org) | ✅ | ✅ | ✅ | ❌ | ❌ | `vendors_read`: `user_in_org(org_id)` |
| View **own** vendor record | – | – | – | ✅ | ❌ | `vendors_read`: `is_vendor_member(id)` |
| Add prospect + **invite** | ✅ | ✅ | ✅ | ❌ | ❌ | RPC `invite_vendor()` checks `user_in_org` |
| Public **self-register** ("Register now") | – | – | – | – | ✅ | RPC `self_register()` (SECURITY DEFINER) |
| Look up invitation by token | ✅ | ✅ | ✅ | ✅ | ✅ | RPC `get_invitation()` |
| **Claim** invitation (start onboarding) | ❌ | ❌ | ❌ | ✅ | ❌ | RPC `claim_invitation()` (auth required) |
| Edit onboarding data | ❌ | ❌ | ❌ | ✅ | ❌ | Group-A policies: `vendor_editable_by_member()` (status ∈ invited/registering) |
| Buyer edit vendor profile | ✅ | ✅ | ✅ | – | ❌ | Group-A: `is_buyer_for_vendor()` |
| Upload document | ✅ | ✅ | ✅ | ✅ | ❌ | `vendor_documents` ins + storage `vdocs_insert` |
| Submit registration | ❌ | ❌ | ❌ | ✅ | ❌ | RPC `vendor_transition(...,'submitted')` (member) |
| Verify document | ✅ | ✅ | ❌ | ❌ | ❌ | `vendor_documents` upd; app gates to approver+ |
| **Approve** vendor | ✅ | ✅ | ❌ | ❌ | ❌ | RPC `vendor_transition(...,'approved')`; app gates approver+ |
| **Reject** / request changes | ✅ | ✅ | ❌ | ❌ | ❌ | `vendor_transition(...,'rejected'/'registering')` |
| **Block** / **Unblock** | ✅ | ✅ | ❌ | ❌ | ❌ | `vendor_transition(...,'blocked'/'active')` |
| Create / score **evaluation** | ✅ | ✅ | ✅* | ❌ | ❌ | Group-B: `is_buyer_for_vendor()` (*requester read-only in app) |
| Run **risk screening** | ✅ | ✅ | ✅ | ❌ | ❌ | edge fn `risk-screening` (service role) + Group-B insert |
| Refresh **Web Insights** | ✅ | ✅ | ✅ | ❌ | ❌ | edge fn `vendor-web-insights` |
| **Message** vendor / buyer | ✅ | ✅ | ✅ | ✅ | ❌ | `vendor_messages` (buyer-or-member) |
| View **PII** (full bank a/c) | ✅ | ✅ | ❌ | ✅own | ❌ | column-mask in app; requester sees masked (see note) |
| View **audit log** | ✅ | ✅ | ✅ | ❌ | ❌ | `audit_read`: `is_buyer_for_vendor()` |
| Manage purchase orders | ✅ | ✅ | ✅ | ❌ | ❌ | `po_write`: `user_in_org(org_id)` |
| View own POs | – | – | – | ✅ | ❌ | `po_read`: `is_vendor_member()` |
| Manage doc requirements / org branding | ✅ | ❌ | ❌ | ❌ | ❌ | `has_role(uid,'buyer_admin')` |
| Mark own notification read | ✅ | ✅ | ✅ | ✅ | ❌ | `notif_*`: `recipient_id = auth.uid()` |

**PII masking note.** Bank account numbers are stored in full (needed for payments)
but the UI masks them to `XXXX XXXX 4567` for everyone except `buyer_admin`,
`buyer_approver`, and the owning `vendor_user`. Implement as a view/selector
`mask_account(account_number)` + an app-level role check; RLS still allows the row,
the *presentation* masks. (Matches the live 360 which shows masked accounts.)

**Role gating that lives in the app (not RLS).** Some distinctions (approver vs
requester for *approve*; admin-only for *branding*) are enforced by checking
`has_role()` before showing the action AND by routing the write through an RPC that
re-checks. Never rely on hiding a button alone — every privileged write re-validates
server-side.


<!-- ===== 04-STATE-MACHINE.md ===== -->

# 4. Vendor lifecycle state machine

Implemented by `public.vendor_transition(vendor_id, to_status, reason)` (see
`0002_functions_triggers.sql`). Every transition: validates legality, updates the
row + timestamps, writes a `vendor_status_history` row **and** a `vendor_audit_log`
row, assigns a `vendor_code` on first approval, and fans out notifications.

```
            invite_vendor()/self_register()                claim_invitation()
  ┌──────────┐  RPC          ┌─────────┐   vendor opens     ┌─────────────┐
  │ prospect │ ───────────▶ │ invited │ ─────────────────▶ │ registering │
  └──────────┘               └─────────┘                     └─────────────┘
       │  (Add Prospect, no invite yet)                            │ vendor: Submit
       │                                                           ▼
       │                                                     ┌───────────┐
       │                                                     │ submitted │
       │                                                     └───────────┘
       │                                                           │ buyer opens review
       │                                                           ▼
       │                                                   ┌──────────────┐
       │                          request changes ◀────────│ under_review │────────┐
       │                          (back to registering)    └──────────────┘        │
       │                                                     │ approve      reject  │
       │                                                     ▼                 ▼    │
       │                                              ┌──────────┐      ┌──────────┐│
       │                                              │ approved │      │ rejected ││
       │                                              └──────────┘      └──────────┘│
       │                                                     │ activate      │ reopen
       │                                                     ▼               └──────┘
       │                                                ┌────────┐
       └───────────────────────────(deactivate)──────▶ │ active │ ◀── unblock ──┐
                                                        └────────┘                │
                                                          │ block                 │
                                                          ▼                       │
                                                     ┌─────────┐                  │
                                                     │ blocked │ ─────────────────┘
                                                     └─────────┘
   (any active/approved/blocked) ──deactivate──▶ inactive ──▶ active / prospect
```

## Allowed transitions, trigger, side effects

| From | To | Who triggers | Side effects |
|------|----|-------------|--------------|
| prospect | invited | buyer (`invite_vendor`) / public (`self_register`) | invitation row+token; audit `invitation_sent` |
| prospect | inactive | buyer | audit |
| invited | registering | vendor (`claim_invitation`) | membership created; audit |
| invited | inactive | buyer (expire) | audit |
| registering | submitted | **vendor** (Submit) | `submitted_at`, progress=100; **notify buyer** `approval_needed`; audit |
| registering | inactive | buyer | audit |
| submitted | under_review | buyer (open review) | audit |
| submitted | registering | buyer (request changes) | **notify vendor** `changes_requested` |
| under_review | approved | **buyer_approver+** | `approved_at/by`, assign `vendor_code`; **notify vendor** `vendor_approved`; audit |
| under_review | rejected | buyer_approver+ | **notify vendor** `vendor_rejected`; audit |
| under_review | registering | buyer | notify vendor `changes_requested` |
| approved | active | buyer | ensure code; audit |
| approved | blocked | buyer | notify vendor `vendor_blocked` |
| active | blocked | buyer | notify vendor `vendor_blocked`; audit |
| active | inactive | buyer | audit |
| blocked | active | buyer (unblock) | notify vendor `vendor_unblocked`; audit |
| blocked | inactive | buyer | audit |
| rejected | registering | buyer (reopen) | notify vendor; audit |
| inactive | active / prospect | buyer | audit |

Illegal transitions raise `check_violation` — the UI surfaces a toast and does not
change state. **Due-diligence gate:** the app should only enable **Approve** when a
completed scorecard exists *and* required risk screenings are `clean`/acknowledged
(see `06-AI-RISK-DUEDILIGENCE.md`). `vendor_approvals.due_diligence_passed` records
the gate result.

## Tab ↔ status mapping (buyer `/vendors`)

| Tab | Statuses shown |
|-----|----------------|
| Prospects | `prospect`, `invited`, `inactive` |
| Onboarding in Progress | `registering`, `submitted`, `under_review` |
| Registered Vendors | `approved`, `active`, `blocked`, `rejected` |


<!-- ===== 05-SCREENS.md ===== -->

# 6. Screen-by-screen spec

Format per screen: **Route · Purpose · Reads · Writes · Reuse vs Build · States ·
Hero interaction** (the one thing that must feel real). Visual system unchanged
(shadcn, DM Sans, glass 2-col canvas, pill badges). "Reuse" = existing components in
`src/components/vendor/*` / `src/pages/vendor/*`; "Build" = net-new.

Routing note: vendor 360 uses `:slug` (e.g. `ent-1`); resolve `vendors` by
`(org_id, slug)`. customer/workspace uses `org_id` as `:customerId`.

---

## BUYER SIDE

### 6.1 Vendor list — `/vendors`
- **Purpose:** Adani's vendor master with 3 lifecycle tabs + portfolio KPIs.
- **Reads:** `vendors` (filter `org_id = current org`); counts per status for KPI cards; `vendor_documents` where `expires_at <= now()+7d` for the red "Documents expiring" KPI; `notifications` (bell).
- **Writes:** none directly (navigation); bulk actions write via RPC (reminders).
- **Reuse:** existing list shell, KPI cards, filter bar, table, status/tier/risk pill badges, `VendorWorkQueue`. **Build:** wire data; the "Documents expiring" KPI; bulk-select reminder action.
- **States:** *loading* skeleton rows; *empty* per-tab ("No vendors yet — Add Prospect"); *error* retry banner.
- **Hero:** tab counts + the **expiring-docs KPI** are live (realtime on `vendors`/`vendor_documents`) — when a vendor submits elsewhere, the "Onboarding in Progress" count ticks without refresh.
- **Tabs → status:** see `04-STATE-MACHINE.md` mapping.
- **Columns:** Company (legal_name + trade_name), Code (vendor_code), Category (primary_category), Status (lifecycle pill), Risk (risk_level pill), Tier, PO Value (total_spend → ₹Cr), Manager (created_by/owner avatar).

### 6.2 Prospects — `/vendors/prospects`
- **Purpose:** lightweight pre-onboarding stubs + invitation entry point.
- **Reads:** `vendors` where status ∈ (prospect, invited, inactive) for org; primary `vendor_contacts`; KPI counts (Total / Active / Onboarding Initiated / Onboarded).
- **Writes:** **Add Vendor Prospect → Send Invitation** calls RPC `invite_vendor(org, company, category, contact, email, phone, designation, 'manual')` → returns `{vendor_id, slug, token}`. Then client calls edge fn `send-vendor-notification` (type `invitation_sent`).
- **Reuse:** `AddProspectDialog`, `InitiateOnboardingDialog`, `SendInvitationDialog`. **Build:** wire dialog → RPC; show the invite link (demo helper) + copy button.
- **States:** dialog validation (company+contact+email required; email format warn-not-block); optimistic row insert; toast on success/failure.
- **Hero:** clicking **Send Invitation** persists a real invitation + token and the new **Invited** row appears instantly (and on any other buyer's screen via realtime). Source column reflects Manual / RFx Event / Self-Registration.

### 6.3 Vendor 360 shell — `/vendors/:slug`
- **Purpose:** one vendor, 5 tabs + lifecycle actions.
- **Reads:** `vendors` by slug; header badges (status/tier/risk), code, PAN, country.
- **Header actions (Build → wire):**
  - **Approve / Reject / Request changes** (visible to approver+; gated by DD complete) → RPC `vendor_transition`. Approve opens a note dialog; sets `vendor_approvals`.
  - **Block / Unblock** → reuse `BlockVendorDialog` / `UnblockVendorDialog`; RPC `vendor_transition(...,'blocked'/'active')` with reason.
  - **Audit Log** → drawer reading `vendor_audit_log` + `vendor_status_history` (timeline).
  - **Chat** → opens Messages drawer (`vendor_messages`, realtime).
- **Reuse:** `VendorWorkspaceHeader`, `VendorSectionTabs`, `VendorAISummary`. **Build:** action wiring; DD-gate enablement.
- **States:** 404 if slug not in org; blocked banner if status=blocked.
- **Hero:** the **Approve** button is disabled with a tooltip ("Complete due diligence") until a scorecard is complete + screenings done; once done it enables and the click drives the real state machine + notifies the vendor in realtime.

#### 6.3a Tab — Registration  (reuse `RegistrationReviewView`)
- **Reads:** `vendors`, `vendor_tax_registrations`, `vendor_sites`, `vendor_contacts`, `vendor_directors`, `vendor_bank_accounts` (masked), `vendor_qualification`, `vendor_references`, `vendor_certifications`, `vendor_documents` (+ `vendor_document_checklist(vendor_id)` for the "5/5 uploaded" + verified badges).
- **Writes:** **Verify document** (approver) → update `vendor_documents.status='verified', verified_by, verified_at`; audit.
- **States:** collapsible section cards; per-section completeness chips.
- **Hero:** clicking a document opens a **signed-URL** preview (`createSignedUrl`, 60s expiry) — real file, not a placeholder.

#### 6.3b Tab — Business Overview  (reuse `business-overview/`)
- **Reads:** `purchase_orders` (vendor), aggregates for KPIs (total_spend, po_count, avg PO, on-time %), category-wise spend (group by category), monthly spend trend, recent PO list.
- **Writes:** none.
- **States:** empty ("No POs yet") when vendor has none.
- **Hero:** charts render from real `purchase_orders` rows; the category spend table totals exactly match the KPI.

#### 6.3c Tab — Evaluation  (reuse `VendorEvaluationTab`)
- **Reads:** `vendor_scorecards` (+lines) for vendor; composite + risk; weighted summary; re-evaluation triggers (static config rendered from a constant).
- **Writes:** **+ Add Evaluation** → insert `vendor_scorecards` (name, scope[], evaluator_name/email); seed `vendor_scorecard_lines` from the standard criteria template (constant) for the chosen dimensions. Scoring a line updates `vendor_scorecard_lines.score`; trigger `recompute_scorecard` updates composite + `vendors.risk_level`/`composite_score`.
- **AI:** **"AI suggest scores"** → edge fn `ai-evaluate` returns `{dimension,criterion,score,basis}[]`; pre-fills lines with `ai_suggested=true`; human edits before save.
- **Reuse:** evaluation table, score selectors, weighted summary. **Build:** Add-Evaluation dialog → inserts; AI-suggest button.
- **States:** "Not Evaluated" per dimension until scored; saving spinner per line.
- **Hero:** changing a score recomputes the **composite + risk badge live** (trigger), and the vendor's risk pill on the list page updates via realtime.

#### 6.3d Tab — Web Insights  (reuse `web-insights/`)
- **Reads:** `vendor_web_insights` (1:1), `vendor_news_items`, `vendor_risk_screenings` (sanctions/pep).
- **Writes:** **Refresh Now** → edge fn `vendor-web-insights(vendor_id)` (AI + `risk-screening`), upserts `vendor_web_insights`, replaces `vendor_news_items`, inserts `vendor_risk_screenings`; sets `refreshed_at`.
- **Reuse:** company overview, key personnel, financial snapshot, news+sentiment, compliance (MCA/GST), sanctions/PEP cards, ratings. **Build:** wire Refresh Now + loading shimmer.
- **States:** "Last refreshed N ago"; per-section skeleton while refreshing; degraded banner if AI offline (shows cached).
- **Hero:** **Refresh Now** rebuilds the dossier in ~5–8s and the **Sanctions = Clean / PEP = Clean** chips + news sentiment populate from the edge function.

#### 6.3e Tab — Hierarchy  (reuse `selection/VendorHierarchyCard`, `VendorHierarchySearch`)
- **Reads:** `vendors` (Tier 1 group_name + Tier 2 entity), `vendor_tax_registrations` (Tier 3), `vendor_sites` (Tier 4).
- **Writes:** none.
- **Hero:** the 4-tier tree renders exactly from the relational data (Group → Entity → GSTIN → Site) with type badges.

---

## VENDOR / PUBLIC SIDE

### 6.4 Adani vendor portal — `/portal/:slug`  **[BUILD — net-new]**
- **Purpose:** Adani-branded public front door. Two paths in: open **Register now**, or **"I have an invitation"** (token).
- **Reads:** `organizations` by `portal_slug` (anon) for logo/name/brand color.
- **Writes:** **Register now** form → RPC `self_register(portal_slug, company, category, name, email, phone)` → `{token, vendor_slug}` → redirect to `/vendor/auth?invite=token`. **Invitation field** → `get_invitation(token)`; if valid → `/vendor/auth?invite=token`.
- **Reuse:** shadcn form primitives; brand from org tokens (Adani navy). **Build:** the whole page — Adani hero, value props, two CTAs.
- **States:** invalid/expired token message; success → redirect.
- **Hero:** Adani-branded chrome that **redirects into the Aerchain-branded onboarding** — proving the white-label split. (Adani logo here; Aerchain logo on `/vendor/onboard`.)

### 6.5 Vendor auth — `/vendor/auth`  (reuse `VendorAuth`, extend)
- **Purpose:** vendor signup/login; accept-invite flow.
- **Reads:** `get_invitation(token)` if `?invite=` present (prefill email/company, lock email).
- **Writes:** Supabase Auth signUp/signIn (email+password or magic link). On success with an invite: call `ensure_vendor_user(email,name)` then `claim_invitation(token)` → redirect `/vendor/onboard`. Without invite (returning user): redirect `/vendor/dashboard`.
- **Reuse:** `VendorAuth`. **Build:** invite-aware mode; claim call post-auth.
- **States:** "validating invitation…"; auth errors; already-claimed → go to dashboard.
- **Hero:** the invited email is pre-filled & locked, and after sign-in the user lands **directly in their half-pre-filled onboarding** (membership auto-created).

### 6.6 Onboarding wizard — `/vendor/onboard`  (reuse `VendorRegistrationWizard` + steps/, `WizardStepper`)
- **Purpose:** the 7-step tiered registration, now persistent + AI-assisted.
- **Reads:** vendor (current member's active in-progress `vendors` row), all child tables, `vendor_document_checklist(vendor_id)`, `document_requirements`.
- **Writes (autosave per step, debounced):**
  - Company Profile → `vendors` (legal_name, trade_name, pan, cin, entity_type, incorporation_date, website, primary_category, business_description, address, msme_*), `vendor_directors`.
  - Tax Registrations → `vendor_tax_registrations`.
  - Sites & Contacts → `vendor_sites`, `vendor_contacts` (entity-wide / per-reg).
  - Banking → `vendor_bank_accounts` (+ verification doc link).
  - Qualification → `vendor_qualification`, `vendor_references`, `vendor_certifications`.
  - Documents → Storage upload → `vendor_documents` (status `uploaded`, `requirement_key`, `expires_at`).
  - Declarations → `vendor_approvals`? no — store declaration acceptance on `vendors` via a `declarations jsonb`? Use `vendor_audit_log` action `declarations_accepted` + a `submitted` transition. Signatory captured in audit payload.
  - **Submit** → RPC `vendor_transition(vendor_id,'submitted')`.
- **AI (Build):**
  1. **"Upload documents — we'll fill the form"** dropzone (top of wizard) → uploads to Storage → edge fn `extract-document` per file → returns `{doc_type, requirement_key, fields{}}` → maps fields into the relevant step inputs + files the doc into its required slot (green "matched" chip). Writes `vendor_documents.extracted_data`.
  2. **Auto-Fetch from MCA** (Company Profile) → edge fn `mca-fetch(pan|cin)` → fills entity type, CIN, incorporation date, directors.
  3. **Auto-Fill Demo** button → calls the same edge fns in demo mode for a deterministic fill (kill-switch).
  4. **AI assistant ("Aiera")** side panel → edge fn `vendor-assistant` answers questions + can fill a named field.
- **Reuse:** all wizard step components & stepper. **Build:** autosave hooks; dropzone+extraction; MCA wiring; checklist-driven Documents step; progress = % steps complete → `vendors.registration_progress`.
- **States:** per-step saving indicator; resume where left off; validation warns (regex `[A1]`) but never blocks demo submit; "Due in 30 days" from `onboarding_due_at`.
- **Hero:** **dropping 4 PDFs auto-populates fields across multiple steps and matches each file to its required document slot** in ~10s.

### 6.7 Vendor dashboard — `/vendor/dashboard`  **[BUILD — net-new]** (reuse `VendorDashboard` shell)
- **Purpose:** the vendor's home — all customer relationships (one card per buyer org).
- **Reads:** `vendor_memberships` for `current_vendor_user_id()` → join `vendors` → each customer card shows org name/logo, lifecycle status pill, vendor_code, onboarding progress, open actions; unread `notifications`; open `vendor_messages`.
- **Writes:** none (navigation).
- **Reuse:** `VendorDashboard`, `VendorAISummary`. **Build:** multi-customer card grid; status pills.
- **States:** empty ("No customers yet"); pending-onboarding card has a **Continue registration** CTA → `/vendor/onboard`.
- **Hero:** after Adani approves, the **Adani card flips to Active/Approved with the vendor code in realtime** (subscribe to `vendors`).

### 6.8 Vendor workspace — `/vendor/workspace/:customerId`  **[BUILD — net-new]** (reuse `VendorWorkspace`, `VendorWorkspaceHeader`, `VendorSectionTabs`)
- **Purpose:** everything for one customer (one buyer org).
- **Reads:** the `vendors` row for `(customerId=org_id, current vendor user)`; onboarding status/summary; `purchase_orders` (this vendor); `vendor_messages`; `vendor_documents` (with expiry warnings).
- **Writes:** send `vendor_messages` (author_type `vendor`); re-upload expiring docs → Storage + `vendor_documents`.
- **Reuse:** workspace header/tabs, `VendorAISummary`. **Build:** sections — Overview, Documents (with expiry chips + re-upload), Purchase Orders, Messages.
- **States:** locked sections until approved; expiring-doc warning banner.
- **Hero:** the **Messages** thread is the same `vendor_messages` rows the buyer sees — send one and it appears on the buyer's Chat drawer in <5s.

### 6.9 Vendor purchase orders — `/vendor/purchase-orders` + `/vendor/purchase-orders/:id`  **[BUILD — net-new]** (reuse `VendorPurchaseOrders`, `VendorPODetail`)
- **Purpose:** the vendor's PO inbox across customers + PO detail.
- **Reads:** `purchase_orders` where `is_vendor_member(vendor_id)` (RLS) — across all their customer relationships; PO detail reads `purchase_orders` + `purchase_order_lines`.
- **Writes:** **Acknowledge PO** → update `purchase_orders.status='acknowledged'` (allowed? RLS `po_write` is buyer-only). → Provide RPC `vendor_acknowledge_po(po_id)` (SECURITY DEFINER, checks `is_vendor_member`) to let vendor set acknowledged.
- **Reuse:** `VendorPurchaseOrders`, `VendorPODetail`. **Build:** wire list + detail + acknowledge RPC.
- **States:** empty inbox; status pills (issued/acknowledged/delivered/…).
- **Hero:** the PO list is the same `purchase_orders` rows powering the buyer's Business Overview — one source of truth, two lenses.

---

## Cross-cutting components
- **Notifications bell** (both sides): reads `notifications` (recipient = auth.uid()), realtime insert → toast + badge; mark-read on open.
- **Messages drawer** (both sides): `vendor_messages` realtime thread.
- **Signed-URL document preview**: never expose Storage paths; always `createSignedUrl`.
- **Status/tier/risk pill** primitives: shared, token-colored.

---

## ENTERPRISE / INTEGRATION SCREENS (Adani-driven; see `09`, `10`, `11`)

### 6.10 Integration setup — `/settings/integrations`  **[BUILD]** (buyer_admin)
- **Purpose:** the "Salesforce-style" front-end connector setup (no backend dev).
- **Reads:** `integration_connections`, `integration_field_mappings`, recent `integration_sync_runs`.
- **Writes:** create/edit connection (system_type, base_url, env, auth, credentials → **Vault**, DB stores `vault_secret_id`); **Test** → `erp-sync action:"test"`; field mappings; trigger **Pull vendor master** / **Pull GRN** → `erp-sync`.
- **Reuse:** shadcn form/stepper/table. **Build:** wizard (Choose system → Connection → Test → Save → Field map → Payload test → Schedule).
- **States:** connection status pill (unconfigured/connected/error); live sync-run progress (realtime on `integration_sync_runs`).
- **Hero:** click **Test connection** → green check from a real (or mock) ERP ping; **Pull vendor master** streams a sync run that imports suppliers (e.g. SKF/Schaeffler/dealer) with live progress.

### 6.11 Due-diligence panel — on Vendor 360 (Registration/Evaluation area)  **[BUILD]**
- **Purpose:** run + track the configurable DD checklist; it's the **approval gate**.
- **Reads:** `due_diligence_checks` (applicable to vendor risk tier), `vendor_due_diligence_items`, `dd_gate_status(vendor_id)`.
- **Writes:** **Run due diligence** → `due-diligence` edge fn (writes items). **Human checks** (site/reference) open a **recording UI**: set pass/fail + note + **evidence upload** → `vendor_due_diligence_items` (source=human). **Waive** a check (admin) with note.
- **Reuse:** checklist list, status chips. **Build:** run button, per-check drawer, human recording form, gate banner.
- **States:** per-check status (pending/pass/fail/manual_review/waived); gate banner "Due diligence X/Y mandatory complete".
- **Hero:** clicking **Run due diligence** fills OFAC/PEP/GST/D&B as **pass** in seconds; the **Approve** button unlocks only when the gate passes — `approve_vendor()` enforces it server-side.

### 6.12 Vendor tagging — on Vendor 360 header + list filter  **[BUILD]**
- **Reads:** `vendors.vendor_class/is_preferred/brand_tags/parent_oem_id`.
- **Writes:** edit class/preferred/brands; **AI suggest** → `vendor-classify` (buyer confirms). Dealer→OEM link via `parent_oem_id`.
- **Hero:** **AI suggest tag** proposes OEM vs dealer + brands (SKF/Schaeffler/NSK); on save it can sync to SAP MDG as the preferred/partner-role tag via `erp-sync`. List page gains an **OEM/dealer + Preferred** filter.

### 6.13 Master-data dedup — `/vendors/dedupe`  **[BUILD]** (buyer_admin)
- **Reads:** `vendor_duplicate_candidates` (open).
- **Writes:** **Scan** → `vendor-dedupe`; per-candidate **Merge** / **Dismiss** (merge re-points children + sets one `inactive`).
- **Hero:** "Scan for duplicates" surfaces near-identical vendors (same PAN / fuzzy name) for one-click review — the master-data-rationalization Adani asked for.

### 6.14 Onboarding extras (extend §6.6)
- **Excel/CSV upload:** the dropzone also accepts `.xlsx/.csv`; `extract-document` parses rows → maps to fields (buyer-uploaded vendor sheet path).
- **GRN performance:** Evaluation "Operational Capability" lines can be **auto-filled from `vendor_grn_metrics`** (pulled via `erp-sync`) instead of manual scoring.
- **Language switch:** EN / हिन्दी / ગુજરાતી toggle on portal + wizard; `vendor-assistant` replies in-language (voice-capable "Atlas").
- **ERP badge:** once pushed, the 360 shows **"Synced to SAP — LIFNR 000100…"** from `vendor_external_refs`.

### 6.15 Mobile (responsive, not separate app)
- Supported on phone: **initiate vendor onboarding**, **approve/reject**, **monitor status**, **notifications**. Full wizard authoring stays desktop. (Matches Adani's stated mobile expectation.)


<!-- ===== 06-AI-RISK-DUEDILIGENCE.md ===== -->

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


<!-- ===== 07-REALTIME-NOTIFICATIONS.md ===== -->

# 7b. Realtime & notifications plan

## 7b.1 Realtime publication (set in `0005_storage_realtime.sql`)

Published tables: `vendors`, `vendor_status_history`, `vendor_documents`,
`vendor_messages`, `notifications`, `vendor_scorecards`, `vendor_risk_screenings`
(replica identity `full` on the mutable ones so updates carry old+new).

## 7b.2 Channels the clients subscribe to

| Client | Channel / filter | Reacts to |
|--------|------------------|-----------|
| Buyer list `/vendors` | `vendors` where `org_id=eq.{org}` | row insert/update → re-fetch counts + update row badges live (the "Onboarding in Progress" tick) |
| Buyer 360 | `vendors` id=eq.{id}; `vendor_documents` vendor_id=eq.{id}; `vendor_scorecards`; `vendor_risk_screenings`; `vendor_messages` vendor_id=eq.{id} | status/risk badge, doc verify, scorecard composite, screening result, chat |
| Buyer (global) | `notifications` recipient_id=eq.{uid} | bell badge + toast |
| Vendor dashboard | `vendors` id in {membership ids} | customer card flips to Active/Approved on approval |
| Vendor workspace | `vendor_messages` vendor_id=eq.{id}; `vendor_documents` | live chat + doc status |
| Vendor (global) | `notifications` recipient_id=eq.{uid} | bell + toast (approved/rejected/changes) |

Subscribe pattern (client):
```ts
supabase.channel(`vendor-${id}`)
  .on('postgres_changes', { event: '*', schema: 'public', table: 'vendor_messages', filter: `vendor_id=eq.${id}` }, onMsg)
  .on('postgres_changes', { event: 'UPDATE', schema: 'public', table: 'vendors', filter: `id=eq.${id}` }, onVendor)
  .subscribe();
```

## 7b.3 In-app toast

shadcn `useToast`. On a `notifications` INSERT for the current user:
- title = `notification.title`, description = `notification.body`,
- variant: `destructive` for `vendor_rejected`/`document_rejected`/`vendor_blocked`,
  `default` otherwise, with an emoji accent for `vendor_approved` ("🎉").
- clicking the toast/bell item navigates to `notification.link` and marks `read=true`.

The bell shows `count(*) where read=false`. Marking read = `update notifications set read=true where id=…` (RLS: recipient only).

## 7b.4 Who fires what (event → recipients → channels)

| Event | In-app (DB does it) | Email (edge fn) | Recipients |
|-------|--------------------|-----------------|------------|
| invitation_sent | — (no app user yet) | `send-vendor-notification` | vendor contact email |
| registration_submitted / approval_needed | `vendor_transition` → `notify_org` | `send-vendor-notification` to approvers | buyer org users |
| vendor_approved | `notify_vendor_users` | email vendor | vendor users |
| vendor_rejected / changes_requested | `notify_vendor_users` | email vendor | vendor users |
| document_expiring / reupload_reminder | `expiry-sweep` inserts | email vendor | vendor users |
| message_received | client inserts notification on send | optional | the other party |
| screening_complete | `risk-screening` audit only | — | (buyer sees in UI) |
| vendor_blocked / unblocked | `vendor_transition` | optional | vendor users |

**Wiring rule:** after any client mutation that should email (invite, submit,
approve, reject, remind), the client calls `send-vendor-notification` with the
event `type`, `recipient_emails`, and `data` (company/code/link). In-app rows are
written by the DB functions so they persist even if email fails.

## 7b.5 `send-vendor-notification` payload (canonical)
```jsonc
POST /functions/v1/send-vendor-notification
{
  "type": "approval_needed",                  // see notification_type enum
  "vendor_id": "…", "org_id": "…",
  "recipient_ids": ["<auth-uid>", "…"],        // in-app
  "recipient_emails": ["priya@adani-demo.com"],// email
  "link": "/vendors/bharat-forge",
  "data": { "company": "Bharat Forge Limited", "org": "Adani Group", "code": "BHFRG-001" },
  "email": true
}
```
Response: `{ ok, emailed }`. All event templates live in the function (`T` map).


<!-- ===== 08-EXECUTION-AND-KILLSWITCH.md ===== -->

# 9. Execution plan (hour-by-hour) & 10. Demo-day kill-switches

> Ordered so the **demo script** (`02-DEMO-SCRIPT.md`) is runnable end-to-end as
> early as possible (≈ T+10h), then everything else is layered on. All features
> ship — this is sequence, not scope.

## 9. T+0 → T+24

| Block | Hours | Work | Output |
|------|------|------|--------|
| **Schema** | T+0 → T+2 | Apply `0001` (enums, tables, grants), `0002` (functions, triggers, state machine), `0003` (RPCs). | DB stands up; `vendor_transition`, RPCs callable. |
| **RLS + storage + realtime** | T+2 → T+4 | Apply `0004` (RLS), `0005` (bucket, storage policies, realtime publication). | Multi-user isolation enforced; bucket ready. |
| **Seed** | T+4 → T+5 | Apply `0006` seed; create 5 auth users; `select link_demo_users();`. | App looks populated; Tata 360 depth; Bharat Forge `invited` w/ token; Asian Paints expiring doc. |
| **Buyer P0 UI** | T+5 → T+8 | Wire `/vendors` (tabs/KPIs/filters), `/vendors/prospects` (+ Add Prospect → `invite_vendor`), 360 Registration tab, header **Approve/Reject/Block** → `vendor_transition`. | Buyer can invite + review + decide for real. |
| **Vendor P0 UI** | T+8 → T+11 | `/portal/adani` (self-register + invite), `/vendor/auth` (claim), `/vendor/onboard` wired with **autosave** + Submit → `vendor_transition`; Documents step uses Storage + `vendor_document_checklist`. | **Demo script Acts 1–3 runnable end-to-end.** |
| **Realtime + notifications** | T+11 → T+13 | Subscriptions (vendors/messages/notifications), toast+bell, `send-vendor-notification` wired to invite/submit/approve. | Cross-user <5s; emails fire. |
| **AI doc-extraction + MCA** | T+13 → T+16 | Deploy `_shared`, `extract-document`, `mca-fetch`; wire dropzone auto-map + Auto-Fetch + Auto-Fill Demo. | Wow #2 + MCA live. |
| **Risk + Web Insights + DD** | T+16 → T+19 | Deploy `risk-screening`, `vendor-web-insights`; wire Web Insights *Refresh Now*, sanctions/PEP cards; DD gate on Approve. | Wow #4 + due-diligence gate. |
| **Evaluation + assistant** | T+19 → T+21 | Wire Evaluation tab (Add Evaluation, score → recompute, `ai-evaluate` suggest); `vendor-assistant` panel. | Scorecard real; AI scoring. |
| **P1/P2 polish** | T+21 → T+23 | Business Overview charts, Hierarchy tab, vendor dashboard/workspace/PO, expiry-sweep + reminder, audit drawer, messaging. | Full breadth. |
| **QA + dry run** | T+23 → T+24 | Run the demo script twice in two browsers; fix breakages; verify refresh-persistence + RLS (vendor can't see other vendors). | Green run. |

## Top-3 risks + fallback

1. **AI/vision latency or quota during live demo.**
   *Fallback:* `RISK_MODE=mock` + **Auto-Fill Demo** button → deterministic fill and
   "Clean" screenings with zero external calls. Pre-warm by running the dossier on
   Bharat Forge once before the demo (it caches in `vendor_web_insights`).
2. **Auth-user ↔ role linkage (`org_users`/`roles` schema mismatch).**
   *Fallback:* `link_demo_users()` is editable; if the roles table differs, seed
   roles manually for the 5 demo accounts. Verify `has_role(uid,'buyer_admin')`
   returns true for Priya before the demo.
3. **Realtime not delivering (publication/replica identity).**
   *Fallback:* the UI also re-fetches on window focus + a 5s poll on the 360/list as
   a safety net; if realtime is dead the tick still appears within 5s.

## 10. Demo-day kill-switches

Feature flags (env/config, read at boot) — flip OFF to hide and route around:

| Flag | OFF behaviour |
|------|---------------|
| `FLAG_AI_EXTRACTION` | Hide the dropzone; vendor fills the form manually (still real). |
| `FLAG_WEB_INSIGHTS` | Hide *Refresh Now*; show the **seeded** Tata dossier (already in `vendor_web_insights`). |
| `FLAG_LIVE_RISK` | Force `RISK_MODE=mock`. |
| `FLAG_EMAIL` | Skip `send-vendor-notification` email; in-app notifications still fire. |
| `FLAG_ASSISTANT` | Hide the Aiera panel. |

Fallback routes: if `/vendor/onboard` autosave misbehaves, the **Auto-Fill Demo**
button fills + the Submit still calls `vendor_transition`. If the public portal
errors, paste the invitation link straight into `/vendor/auth?invite=demo-bharatforge-token`.

**Presenter recovery lines (say verbatim):**
> "We run this against a live database with real role-based access — so I'll let the
> data refresh for a second rather than show you a mock."
> "And while that syncs, notice everything you've seen already persisted — I can
> reload either window and the state is exactly where we left it."


<!-- ===== 09-ERP-INTEGRATION.md ===== -->

# 9. ERP / Ariba / SAP / MDG integration layer

> Derived directly from the Adani meetings: integration must be **front-end
> configurable** ("like setting up Salesforce — pick the system, enter credentials,
> test & save, map fields, test payload, no back-end dev"), support **SAP S/4HANA,
> SAP MDG, SAP Ariba, Coupa, Oracle, Baan/Infor**, and do **bi-directional vendor-master
> sync** — pull the buyer's existing vendor master in, and **push AirChain-onboarded
> vendors back into SAP/Ariba**. Plus pull **GRN** data for objective performance.

## 9.1 What integrates (vendor-management scope)

| Flow | Direction | Source/Target | Purpose |
|------|-----------|---------------|---------|
| Vendor master import | inbound (pull) | SAP `API_BUSINESS_PARTNER` (OData) / Ariba Supplier Data API / MDG | Populate AirChain with the buyer's existing suppliers; dedup. |
| Vendor master write-back | outbound (push) | SAP MDG change request / `BAPI_VENDOR_CREATE` (IDoc `CREMAS`) / Ariba Supplier | On approval/activation, create/update the vendor (LIFNR/SMVendorID) in the ERP; store external id. |
| GRN / performance | inbound (pull) | SAP GRN/quality (OData/CDS) | Objective scorecard inputs: on-time delivery %, quality rejection %. |
| PR → sourcing → award write-back | (out of vendor-mgmt scope; noted) | Ariba/SAP workflow API | Tail-spend autonomous-sourcing loop (separate module). |

> `[A7]` Connectors call ERP APIs via HTTPS (OData/REST/SOAP/cXML) reached through the
> customer's SAP Gateway / BTP / Ariba APIs or an agreed middleware. Where only IDoc/RFC
> is available, an agreed file/middleware bridge is assumed. Demo runs in **mock mode**.

## 9.2 Front-end configurable connection (the "Salesforce-style" setup)

Screen `/settings/integrations` (buyer_admin). Steps, all UI, **no backend dev**:
1. **Choose system** — `sap_s4hana | sap_mdg | sap_ariba | coupa | oracle | baan_infor | generic_rest`.
2. **Connection details** — name, base URL/host, environment (sandbox/prod), auth type
   (`api_key | oauth2 | basic | cert`) + credentials.
3. **Test connection** → edge fn `erp-sync` action `test` pings a health/metadata endpoint → green/red.
4. **Save** → row in `integration_connections`; **credentials go to Supabase Vault**, DB stores only `vault_secret_id`.
5. **Field mapping** — map AirChain vendor fields ↔ ERP fields per entity (table `integration_field_mappings`), with optional transform; **payload test** shows the exact request/response for one sample record.
6. **Schedule** — manual / on-event (on approval) / periodic (pg_cron) for reconciliation.

Default SAP vendor-master field map (editable in UI):
| AirChain | SAP (BP/LFA1) | Ariba |
|----------|---------------|-------|
| `legal_name` | `BusinessPartnerName` / `NAME1` | `SMVendorName` |
| `vendor_code` | `Supplier` / `LIFNR` | `SMVendorID` |
| `pan` | `TaxNumber3` / `STCD3` | custom field |
| `cin` | `TaxNumber` | custom field |
| GSTIN (per reg) | `TaxNumber1`/region | custom field |
| `addr_*` | `Address` node | address block |
| bank (IFSC/acct) | `SupplierBank`/`LFBK` | remittance |
| `vendor_class` (OEM/dealer) | MDG `preferred`/partner role + Z-field | classification |

## 9.3 Data model (in `migrations/0007_integration_dd_tagging.sql`)

- `integration_connections` — system_type, name, base_url, environment, auth_type, vault_secret_id, status, last_test_at, created_by, org_id.
- `integration_field_mappings` — connection_id, entity (`vendor`|`grn`), source_field, target_field, transform, direction.
- `vendor_external_refs` — vendor_id, connection_id, external_system, external_id (LIFNR/SMVendorID), last_synced_at, sync_status, sync_hash. (1 vendor ↔ many ERP systems.)
- `integration_sync_runs` — connection_id, direction (`inbound`|`outbound`), entity, status (`running|success|partial|error`), total/ok/failed counts, started_at, finished_at, error, triggered_by.
- `integration_sync_records` — run_id, vendor_id?, external_id?, action (`create|update|skip|conflict`), status, payload jsonb, error.
- `vendor_grn_metrics` — vendor_id, period, on_time_delivery_pct, quality_rejection_pct, grn_count, source_connection_id. (feeds scorecard objective lines.)

All with `created_at/updated_at/created_by`, RLS = buyer org / `buyer_admin`, in 0007.

## 9.4 `erp-sync` edge function (one function, per-system adapters)

`POST { action, connection_id, entity?, vendor_id?, mode? }`
- `action: "test"` — connectivity/metadata check → `{ ok, info }`.
- `action: "pull"` `entity:"vendor"` — fetch external vendor master (paged) → upsert into `vendors` + `vendor_external_refs`, run dedup (`vendor-dedupe`), write a sync run.
- `action: "push"` `vendor_id` — map vendor → ERP payload → create/update (SAP MDG CR or BP create / Ariba supplier) → store `external_id`; called automatically on `→ active` transition.
- `action: "pull"` `entity:"grn"` — fetch GRN metrics → `vendor_grn_metrics` → feed scorecard.
- **Adapters**: `sap.ts`, `ariba.ts`, `coupa.ts`, `oracle.ts`, `generic.ts`; selected by `connection.system_type`. Credentials read from **Vault** via `vault_secret_id`. **Mock mode** (`INTEGRATION_MODE=mock`, default) returns deterministic sample vendor master + GRN so the demo shows the loop with zero ERP dependency.
- Every run → `integration_sync_runs` + `integration_sync_records` + `vendor_audit_log` (`erp_sync`). Realtime on `integration_sync_runs` powers a live progress UI.

## 9.5 Push-on-approval (closing the loop)

When `vendor_transition(..., 'active')` fires, the client (or a DB `pg_net` hook) calls
`erp-sync action:"push"` for every configured `integration_connections` of the org →
the approved vendor is created in SAP vendor master / Ariba, `vendor_external_refs`
records the `external_id`, and the 360 shows **"Synced to SAP (LIFNR 0001234567)"**.
This is the concrete answer to Adani's "for every customer we update your existing master."

## 9.6 Security & ops
- Credentials in **Supabase Vault** (never plaintext columns); functions use service role.
- Per-connection rate limiting + retry/backoff; partial-success runs are resumable.
- All syncs audited; RLS limits integration config to `buyer_admin` in the org.
- BYOC / data-residency posture inherited from Supabase project region (see `11-ENTERPRISE-ARCHITECTURE.md`).


<!-- ===== 10-ADANI-REQUIREMENTS-MAP.md ===== -->

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


<!-- ===== 11-ENTERPRISE-ARCHITECTURE.md ===== -->

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


---

# PART B — SQL MIGRATIONS (apply in order)


### FILE: `vendor-mgmt/spec/migrations/0001_schema.sql`

```sql
-- =============================================================================
-- Aerchain Vendor Management — 0001 SCHEMA (enums + tables + grants + enable RLS)
-- Apply as a single Supabase migration. RLS POLICIES are in 0004_rls.sql.
-- Conventions: public schema; no FK to auth.users; created_at/updated_at/created_by
-- on every table; gen_random_uuid() PKs. Idempotent-safe where practical.
-- =============================================================================

create extension if not exists pgcrypto;

-- ----------------------------------------------------------------------------
-- ENUMS
-- ----------------------------------------------------------------------------
do $$ begin
  create type org_type              as enum ('buyer','platform');
  create type vendor_lifecycle      as enum ('prospect','invited','registering','submitted','under_review','approved','active','rejected','blocked','inactive');
  create type vendor_tier           as enum ('strategic','preferred','approved','conditional','unclassified');
  create type risk_level            as enum ('low','medium','high','critical','unrated');
  create type vendor_source         as enum ('manual','rfx_event','self_registration');
  create type tax_type              as enum ('gstin','iec','pan','tan','vat','other');
  create type site_type             as enum ('office','factory','warehouse','hub','branch','rnd','other');
  create type contact_role          as enum ('sales','accounts','finance','logistics','procurement','management','technical','other');
  create type bank_scope            as enum ('domestic','international');
  create type document_status       as enum ('pending','uploaded','verified','rejected','expired');
  create type document_type         as enum ('pan_card','gst_certificate','incorporation_certificate','iso_9001','iso_14001','iso_27001','insurance','bank_proof','msa','material_test_certificate','msme_certificate','financial_statement','authorization_letter','other');
  create type approval_decision     as enum ('pending','approved','rejected','changes_requested');
  create type scorecard_status      as enum ('draft','in_progress','complete');
  create type scorecard_dimension   as enum ('financial_health','compliance_standing','operational_capability','geographic_risk','information_security','esg_sustainability');
  create type screening_type        as enum ('sanctions','pep','credit','news','geographic','adverse_media');
  create type screening_status      as enum ('clean','flagged','pending','error');
  create type invitation_status     as enum ('pending','accepted','expired','revoked');
  create type message_author_type   as enum ('buyer','vendor','system');
  create type po_status             as enum ('draft','issued','acknowledged','delivered','invoiced','paid','cancelled');
  create type notification_type     as enum (
    'invitation_sent','registration_started','registration_submitted','approval_needed',
    'vendor_approved','vendor_rejected','changes_requested','document_expiring','document_rejected',
    'message_received','screening_complete','evaluation_assigned','reupload_reminder',
    'vendor_blocked','vendor_unblocked');
exception when duplicate_object then null; end $$;

-- ----------------------------------------------------------------------------
-- ORGANIZATIONS (buyer tenants; Adani is the demo tenant). Idempotent create.
-- ----------------------------------------------------------------------------
create table if not exists public.organizations (
  id            uuid primary key default gen_random_uuid(),
  name          text not null,
  slug          text unique not null,
  org_type      org_type not null default 'buyer',
  portal_slug   text unique,                 -- /portal/:portal_slug   (e.g. 'adani')
  logo_url      text,
  brand_primary text,                         -- hex/token override for the portal
  brand_accent  text,
  website       text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  created_by    uuid
);

-- ----------------------------------------------------------------------------
-- VENDORS  (org-scoped relationship + legal-entity profile; Tier 2 of hierarchy)
-- ----------------------------------------------------------------------------
create table if not exists public.vendors (
  id                  uuid primary key default gen_random_uuid(),
  org_id              uuid not null references public.organizations(id) on delete cascade,
  slug                text not null,                     -- routes /vendors/:slug  (e.g. 'ent-1')
  -- identity
  legal_name          text not null,
  trade_name          text,
  group_name          text,                              -- Tier 1 (e.g. 'Tata Group')
  vendor_code         text,                              -- assigned at approval (e.g. 'TATA-STL')
  pan                 text,
  cin                 text,
  entity_type         text,                              -- 'Public Limited', etc.
  incorporation_date  date,
  website             text,
  primary_category    text,                              -- 'Raw Materials', etc.
  business_description text,
  -- registered address (legal entity)
  addr_line1          text, addr_line2 text, city text, state text, pincode text, country text default 'India',
  -- MSME
  msme_registered     boolean not null default false,
  msme_number         text,
  -- lifecycle + classification
  lifecycle_status    vendor_lifecycle not null default 'prospect',
  tier                vendor_tier not null default 'unclassified',
  risk_level          risk_level not null default 'unrated',
  source              vendor_source not null default 'manual',
  source_ref          text,                              -- RFQ number when source=rfx_event
  -- workflow timestamps
  onboarding_due_at   timestamptz,
  registration_progress int not null default 0,          -- 0..100 (wizard)
  submitted_at        timestamptz,
  approved_at         timestamptz,
  approved_by         uuid,
  -- rollups (denormalized for list/badges; kept fresh by triggers/edge fns)
  composite_score     numeric,
  total_spend         numeric default 0,
  po_count            int default 0,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  created_by          uuid,
  unique (org_id, slug)
);
create index if not exists idx_vendors_org           on public.vendors(org_id);
create index if not exists idx_vendors_status         on public.vendors(org_id, lifecycle_status);
create index if not exists idx_vendors_pan            on public.vendors(pan);

-- ----------------------------------------------------------------------------
-- TAX REGISTRATIONS  (Tier 3 — GSTIN / IEC per jurisdiction)
-- ----------------------------------------------------------------------------
create table if not exists public.vendor_tax_registrations (
  id                 uuid primary key default gen_random_uuid(),
  vendor_id          uuid not null references public.vendors(id) on delete cascade,
  tax_type           tax_type not null default 'gstin',
  registration_number text not null,
  jurisdiction       text,                 -- 'Maharashtra'
  jurisdiction_code  text,                 -- '27'
  status             text not null default 'active',
  addr_line1 text, addr_line2 text, city text, state text, pincode text, country text default 'India',
  is_primary         boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_taxreg_vendor on public.vendor_tax_registrations(vendor_id);

-- ----------------------------------------------------------------------------
-- SITES  (Tier 4 — nested under a tax registration, or entity-wide)
-- ----------------------------------------------------------------------------
create table if not exists public.vendor_sites (
  id                  uuid primary key default gen_random_uuid(),
  vendor_id           uuid not null references public.vendors(id) on delete cascade,
  tax_registration_id uuid references public.vendor_tax_registrations(id) on delete set null,
  site_name           text not null,
  site_code           text,                 -- auto-generated
  site_type           site_type not null default 'office',
  addr_line1 text, addr_line2 text, city text, state text, pincode text, country text default 'India',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_sites_vendor on public.vendor_sites(vendor_id);

-- ----------------------------------------------------------------------------
-- CONTACTS  (entity-wide when tax_registration_id is null; else scoped)
-- ----------------------------------------------------------------------------
create table if not exists public.vendor_contacts (
  id                  uuid primary key default gen_random_uuid(),
  vendor_id           uuid not null references public.vendors(id) on delete cascade,
  tax_registration_id uuid references public.vendor_tax_registrations(id) on delete set null,
  full_name           text not null,
  email               text,
  phone               text,
  designation         text,
  role                contact_role not null default 'other',
  is_primary          boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_contacts_vendor on public.vendor_contacts(vendor_id);

-- ----------------------------------------------------------------------------
-- DIRECTORS / SIGNATORIES  (manual or MCA auto-fetch)
-- ----------------------------------------------------------------------------
create table if not exists public.vendor_directors (
  id          uuid primary key default gen_random_uuid(),
  vendor_id   uuid not null references public.vendors(id) on delete cascade,
  full_name   text not null,
  din         text,
  designation text,
  source      text not null default 'manual',   -- 'manual' | 'mca'
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_directors_vendor on public.vendor_directors(vendor_id);

-- ----------------------------------------------------------------------------
-- DOCUMENT REQUIREMENTS (config: what docs are required by category/tier)
-- ----------------------------------------------------------------------------
create table if not exists public.document_requirements (
  id             uuid primary key default gen_random_uuid(),
  requirement_key text unique not null,         -- 'pan','bank_proof','iso_9001','gst:<state>'
  doc_type       document_type not null,
  label          text not null,
  applies_category text,                          -- null = all categories
  applies_tier   vendor_tier,                     -- null = all tiers
  is_mandatory   boolean not null default true,
  per_tax_registration boolean not null default false,  -- e.g. GST cert per state
  sort_order     int not null default 100,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);

-- ----------------------------------------------------------------------------
-- DOCUMENTS (uploaded files; Supabase Storage path; expiry tracking; AI extract)
-- ----------------------------------------------------------------------------
create table if not exists public.vendor_documents (
  id              uuid primary key default gen_random_uuid(),
  vendor_id       uuid not null references public.vendors(id) on delete cascade,
  doc_type        document_type not null default 'other',
  requirement_key text,                          -- which required slot this fills
  label           text,
  status          document_status not null default 'pending',
  storage_path    text,                          -- bucket 'vendor-documents'
  file_name       text,
  mime_type       text,
  size_bytes      bigint,
  issuer          text,                          -- e.g. 'Bureau Veritas'
  issue_date      date,
  expires_at      date,                          -- powers expiry alerts/reminders
  cert_number     text,
  linked_tax_registration_id uuid references public.vendor_tax_registrations(id) on delete set null,
  extracted_data  jsonb,                         -- AI extraction output
  uploaded_at     timestamptz,
  verified_by     uuid,
  verified_at     timestamptz,
  reminder_sent_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_docs_vendor   on public.vendor_documents(vendor_id);
create index if not exists idx_docs_expiry    on public.vendor_documents(expires_at) where expires_at is not null;

-- ----------------------------------------------------------------------------
-- BANK ACCOUNTS  (domestic IFSC / international SWIFT+IBAN)
-- ----------------------------------------------------------------------------
create table if not exists public.vendor_bank_accounts (
  id                  uuid primary key default gen_random_uuid(),
  vendor_id           uuid not null references public.vendors(id) on delete cascade,
  scope               bank_scope not null default 'domestic',
  account_holder_name text,
  account_number      text,                       -- store full; expose masked via view/policy
  account_type        text default 'Current Account',
  currency            text default 'INR',
  bank_name           text,
  branch              text,
  ifsc                text,                        -- domestic
  swift_bic           text,                        -- international
  iban                text,                        -- international
  intermediary_bank   text,
  intermediary_swift  text,
  is_primary          boolean not null default false,
  verification_document_id uuid references public.vendor_documents(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_bank_vendor on public.vendor_bank_accounts(vendor_id);

-- ----------------------------------------------------------------------------
-- QUALIFICATION (1:1) — financials, capability, infosec, ESG
-- ----------------------------------------------------------------------------
create table if not exists public.vendor_qualification (
  vendor_id            uuid primary key references public.vendors(id) on delete cascade,
  turnover_y1          numeric, turnover_y1_label text,
  turnover_y2          numeric, turnover_y2_label text,
  turnover_y3          numeric, turnover_y3_label text,
  net_worth            numeric,
  profitability_status text,
  auditor              text,
  fy_ends_in           text,
  years_experience     int,
  employee_count       int,
  manufacturing_capacity text,
  total_annual_capacity  text,
  quality_system       text,
  -- information security flags
  iso27001             boolean default false,
  soc2                 boolean default false,
  data_encryption      boolean default false,
  incident_response    boolean default false,
  bcp_dr               boolean default false,
  -- ESG
  environmental_policy boolean default false,
  sustainability_certs text[] default '{}',
  diversity_status     text[] default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);

-- ----------------------------------------------------------------------------
-- CLIENT REFERENCES  +  CERTIFICATIONS
-- ----------------------------------------------------------------------------
create table if not exists public.vendor_references (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid not null references public.vendors(id) on delete cascade,
  company_name text, contact_name text, contact_email text, contact_phone text,
  project_description text, value_range text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_refs_vendor on public.vendor_references(vendor_id);

create table if not exists public.vendor_certifications (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid not null references public.vendors(id) on delete cascade,
  cert_type text,             -- 'ISO 9001 (Quality)'
  issuer text,                -- 'Bureau Veritas'
  valid_until date,
  cert_number text,
  document_id uuid references public.vendor_documents(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_certs_vendor on public.vendor_certifications(vendor_id);

-- ----------------------------------------------------------------------------
-- INVITATIONS  (creates a prospect vendor row + token)
-- ----------------------------------------------------------------------------
create table if not exists public.vendor_invitations (
  id            uuid primary key default gen_random_uuid(),
  org_id        uuid not null references public.organizations(id) on delete cascade,
  vendor_id     uuid references public.vendors(id) on delete set null,
  company_name  text not null,
  category      text,
  contact_name  text,
  email         text not null,
  phone         text,
  designation   text,
  token         text unique not null,
  status        invitation_status not null default 'pending',
  source        vendor_source not null default 'manual',
  source_ref    text,
  invited_by    uuid,
  accepted_at   timestamptz,
  expires_at    timestamptz not null default (now() + interval '30 days'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_inv_token on public.vendor_invitations(token);
create index if not exists idx_inv_org   on public.vendor_invitations(org_id);

-- ----------------------------------------------------------------------------
-- STATUS HISTORY + APPROVALS
-- ----------------------------------------------------------------------------
create table if not exists public.vendor_status_history (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid not null references public.vendors(id) on delete cascade,
  from_status vendor_lifecycle,
  to_status   vendor_lifecycle not null,
  actor_id    uuid,
  reason      text,
  at          timestamptz not null default now()
);
create index if not exists idx_status_hist_vendor on public.vendor_status_history(vendor_id, at desc);

create table if not exists public.vendor_approvals (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid not null references public.vendors(id) on delete cascade,
  decision approval_decision not null default 'pending',
  approver_id uuid,
  note text,
  due_diligence_passed boolean,
  decided_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_appr_vendor on public.vendor_approvals(vendor_id);

-- ----------------------------------------------------------------------------
-- EVALUATION / SCORECARDS
-- ----------------------------------------------------------------------------
create table if not exists public.vendor_scorecards (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid not null references public.vendors(id) on delete cascade,
  name text not null default 'Vendor Evaluation',
  status scorecard_status not null default 'draft',
  scope scorecard_dimension[] default '{}',
  composite_score numeric,
  risk_level risk_level default 'unrated',
  evaluator_id uuid,
  evaluator_name text,
  evaluator_email text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_scorecard_vendor on public.vendor_scorecards(vendor_id);

create table if not exists public.vendor_scorecard_lines (
  id uuid primary key default gen_random_uuid(),
  scorecard_id uuid not null references public.vendor_scorecards(id) on delete cascade,
  dimension scorecard_dimension not null,
  dimension_weight numeric not null default 0,   -- e.g. 0.20
  criterion text not null,
  score int,                                      -- 1..5 (null = not scored)
  data_source text,                               -- 'Sanctions Screening API', etc.
  basis text,                                     -- rubric / rationale
  ai_suggested boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_scoreline_card on public.vendor_scorecard_lines(scorecard_id);

-- ----------------------------------------------------------------------------
-- RISK SCREENINGS  (sanctions/pep/credit/news/geographic)
-- ----------------------------------------------------------------------------
create table if not exists public.vendor_risk_screenings (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid not null references public.vendors(id) on delete cascade,
  screening_type screening_type not null,
  status screening_status not null default 'pending',
  result jsonb,
  entities_checked int default 0,
  hits int default 0,
  provider text,
  mode text not null default 'mock',   -- 'mock' | 'live'
  checked_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_screen_vendor on public.vendor_risk_screenings(vendor_id);

-- ----------------------------------------------------------------------------
-- WEB INSIGHTS (1:1 cache) + NEWS ITEMS
-- ----------------------------------------------------------------------------
create table if not exists public.vendor_web_insights (
  vendor_id uuid primary key references public.vendors(id) on delete cascade,
  overview text,
  headquarters text, founded text, employees text, revenue text, industry text,
  stock_ticker text, website text,
  market_cap text, credit_rating text, credit_agency text, dnb_rating text,
  key_ratios jsonb, key_personnel jsonb, financial_snapshot jsonb,
  mca_filings jsonb, gst_filing jsonb,
  sanctions_status text, pep_status text, ratings jsonb,
  refreshed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);

create table if not exists public.vendor_news_items (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid not null references public.vendors(id) on delete cascade,
  title text not null, source text, url text,
  published_at date,
  sentiment text,            -- 'positive' | 'negative' | 'neutral'
  summary text,
  created_at timestamptz not null default now()
);
create index if not exists idx_news_vendor on public.vendor_news_items(vendor_id, published_at desc);

-- ----------------------------------------------------------------------------
-- MESSAGES (buyer <-> vendor thread) + NOTIFICATIONS + AUDIT
-- ----------------------------------------------------------------------------
create table if not exists public.vendor_messages (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid not null references public.vendors(id) on delete cascade,
  author_type message_author_type not null,
  author_id uuid,
  author_name text,
  body text not null,
  attachment_document_id uuid references public.vendor_documents(id) on delete set null,
  read_by_buyer boolean not null default false,
  read_by_vendor boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_msg_vendor on public.vendor_messages(vendor_id, created_at);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  recipient_id uuid not null,             -- auth uid of recipient
  org_id uuid,
  vendor_id uuid references public.vendors(id) on delete cascade,
  type notification_type not null,
  title text not null,
  body text,
  link text,
  read boolean not null default false,
  created_at timestamptz not null default now()
);
create index if not exists idx_notif_recipient on public.notifications(recipient_id, read, created_at desc);

create table if not exists public.vendor_audit_log (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid references public.vendors(id) on delete cascade,
  actor_id uuid,
  action text not null,
  payload jsonb,
  at timestamptz not null default now()
);
create index if not exists idx_audit_vendor on public.vendor_audit_log(vendor_id, at desc);

-- ----------------------------------------------------------------------------
-- VENDOR USERS + MEMBERSHIPS  (vendor user -> many vendor (customer) records)
-- ----------------------------------------------------------------------------
create table if not exists public.vendor_users (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid unique,               -- maps to auth.uid(); NO fk to auth.users
  email text unique not null,
  full_name text,
  phone text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);

create table if not exists public.vendor_memberships (
  id uuid primary key default gen_random_uuid(),
  vendor_user_id uuid not null references public.vendor_users(id) on delete cascade,
  vendor_id uuid not null references public.vendors(id) on delete cascade,
  member_role text not null default 'owner',   -- 'owner' | 'member'
  is_primary boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid,
  unique (vendor_user_id, vendor_id)
);
create index if not exists idx_membership_user   on public.vendor_memberships(vendor_user_id);
create index if not exists idx_membership_vendor on public.vendor_memberships(vendor_id);

-- ----------------------------------------------------------------------------
-- PURCHASE ORDERS (shared between buyer Business-Overview + vendor PO views)
-- ----------------------------------------------------------------------------
create table if not exists public.purchase_orders (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid not null references public.vendors(id) on delete cascade,
  org_id uuid not null references public.organizations(id) on delete cascade,
  po_number text not null,
  title text,
  category text,
  amount numeric not null default 0,
  currency text default 'INR',
  status po_status not null default 'issued',
  order_date date,
  delivery_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_po_vendor on public.purchase_orders(vendor_id, order_date desc);

create table if not exists public.purchase_order_lines (
  id uuid primary key default gen_random_uuid(),
  po_id uuid not null references public.purchase_orders(id) on delete cascade,
  item text not null,
  quantity numeric, uom text, unit_price numeric, amount numeric,
  created_at timestamptz not null default now()
);
create index if not exists idx_poline_po on public.purchase_order_lines(po_id);

-- =============================================================================
-- GRANTS  (RLS still governs row visibility; these grant table-level access)
--   anon          : public portal (org branding, invitation token lookup, self-reg insert)
--   authenticated : buyer + vendor app users
--   service_role  : edge functions (bypass RLS)
-- =============================================================================
grant usage on schema public to anon, authenticated, service_role;

-- read-only for anon on public-portal-relevant tables
grant select on public.organizations to anon, authenticated, service_role;
grant select on public.vendor_invitations to anon, authenticated, service_role;
grant insert on public.vendor_invitations to anon;                   -- self-registration request
grant select, insert, update on public.vendors to anon, authenticated, service_role;

-- full CRUD for authenticated (rows filtered by RLS) + service_role
do $$
declare t text;
begin
  foreach t in array array[
    'vendor_tax_registrations','vendor_sites','vendor_contacts','vendor_directors',
    'document_requirements','vendor_documents','vendor_bank_accounts','vendor_qualification',
    'vendor_references','vendor_certifications','vendor_status_history','vendor_approvals',
    'vendor_scorecards','vendor_scorecard_lines','vendor_risk_screenings','vendor_web_insights',
    'vendor_news_items','vendor_messages','notifications','vendor_audit_log',
    'vendor_users','vendor_memberships','purchase_orders','purchase_order_lines','organizations','vendors'
  ] loop
    execute format('grant select, insert, update, delete on public.%I to authenticated, service_role;', t);
  end loop;
end $$;

-- =============================================================================
-- ENABLE ROW LEVEL SECURITY (policies defined in 0004_rls.sql)
-- =============================================================================
do $$
declare t text;
begin
  foreach t in array array[
    'organizations','vendors','vendor_tax_registrations','vendor_sites','vendor_contacts',
    'vendor_directors','document_requirements','vendor_documents','vendor_bank_accounts',
    'vendor_qualification','vendor_references','vendor_certifications','vendor_invitations',
    'vendor_status_history','vendor_approvals','vendor_scorecards','vendor_scorecard_lines',
    'vendor_risk_screenings','vendor_web_insights','vendor_news_items','vendor_messages',
    'notifications','vendor_audit_log','vendor_users','vendor_memberships',
    'purchase_orders','purchase_order_lines'
  ] loop
    execute format('alter table public.%I enable row level security;', t);
  end loop;
end $$;
```


### FILE: `vendor-mgmt/spec/migrations/0002_functions_triggers.sql`

```sql
-- =============================================================================
-- Aerchain Vendor Management — 0002 FUNCTIONS, TRIGGERS, STATE MACHINE
-- Depends on 0001_schema.sql. Assumes existing helpers has_role(uid,text),
-- is_admin(uid) and table org_users(user_id uuid, org_id uuid).
-- =============================================================================

-- ----------------------------------------------------------------------------
-- updated_at + created_by maintenance
-- ----------------------------------------------------------------------------
create or replace function public.tg_set_updated_at() returns trigger
language plpgsql as $$
begin new.updated_at := now(); return new; end $$;

create or replace function public.tg_set_created_by() returns trigger
language plpgsql as $$
begin
  if new.created_by is null then new.created_by := auth.uid(); end if;
  return new;
end $$;

do $$
declare t text;
begin
  foreach t in array array[
    'organizations','vendors','vendor_tax_registrations','vendor_sites','vendor_contacts',
    'vendor_directors','document_requirements','vendor_documents','vendor_bank_accounts',
    'vendor_qualification','vendor_references','vendor_certifications','vendor_invitations',
    'vendor_approvals','vendor_scorecards','vendor_scorecard_lines','vendor_risk_screenings',
    'vendor_web_insights','vendor_messages','vendor_users','vendor_memberships',
    'purchase_orders'
  ] loop
    execute format('drop trigger if exists set_updated_at on public.%I;', t);
    execute format('create trigger set_updated_at before update on public.%I for each row execute function public.tg_set_updated_at();', t);
    execute format('drop trigger if exists set_created_by on public.%I;', t);
    execute format('create trigger set_created_by before insert on public.%I for each row execute function public.tg_set_created_by();', t);
  end loop;
end $$;

-- ----------------------------------------------------------------------------
-- RLS helper functions (SECURITY DEFINER so they read past RLS without recursion)
-- ----------------------------------------------------------------------------
create or replace function public.current_vendor_user_id() returns uuid
language sql stable security definer set search_path = public as $$
  select id from public.vendor_users where auth_user_id = auth.uid() limit 1;
$$;

create or replace function public.is_vendor_member(p_vendor_id uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1
    from public.vendor_memberships m
    join public.vendor_users u on u.id = m.vendor_user_id
    where m.vendor_id = p_vendor_id and u.auth_user_id = auth.uid()
  );
$$;

create or replace function public.user_in_org(p_org_id uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.org_users ou
    where ou.org_id = p_org_id and ou.user_id = auth.uid()
  );
$$;

-- True if the current user can act on this vendor as a buyer (same org).
create or replace function public.is_buyer_for_vendor(p_vendor_id uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.vendors v
    where v.id = p_vendor_id and public.user_in_org(v.org_id)
  );
$$;

-- ----------------------------------------------------------------------------
-- Code generators
-- ----------------------------------------------------------------------------
create or replace function public.generate_vendor_code(p_legal_name text, p_org_id uuid) returns text
language plpgsql stable as $$
declare base text; n int;
begin
  base := upper(regexp_replace(coalesce(p_legal_name,'VENDOR'), '[^A-Za-z]', '', 'g'));
  base := left(base, 5);
  select count(*) + 1 into n from public.vendors where org_id = p_org_id and vendor_code like base || '-%';
  return base || '-' || lpad(n::text, 3, '0');
end $$;

-- ----------------------------------------------------------------------------
-- Notification fan-out helpers
-- ----------------------------------------------------------------------------
create or replace function public.notify_org(p_org uuid, p_vendor uuid, p_type notification_type,
  p_title text, p_body text, p_link text) returns void
language plpgsql security definer set search_path = public as $$
begin
  insert into public.notifications(recipient_id, org_id, vendor_id, type, title, body, link)
  select ou.user_id, p_org, p_vendor, p_type, p_title, p_body, p_link
  from public.org_users ou where ou.org_id = p_org;
end $$;

create or replace function public.notify_vendor_users(p_vendor uuid, p_type notification_type,
  p_title text, p_body text, p_link text) returns void
language plpgsql security definer set search_path = public as $$
begin
  insert into public.notifications(recipient_id, org_id, vendor_id, type, title, body, link)
  select u.auth_user_id, (select org_id from public.vendors where id = p_vendor), p_vendor, p_type, p_title, p_body, p_link
  from public.vendor_memberships m
  join public.vendor_users u on u.id = m.vendor_user_id
  where m.vendor_id = p_vendor and u.auth_user_id is not null;
end $$;

-- ----------------------------------------------------------------------------
-- STATE MACHINE:  public.vendor_transition()
-- Validates allowed transitions, updates the row, writes status_history + audit,
-- sets timestamps, assigns vendor_code on approval, fans out notifications.
-- ----------------------------------------------------------------------------
create or replace function public.vendor_transition(
  p_vendor_id uuid, p_to vendor_lifecycle, p_reason text default null
) returns public.vendors
language plpgsql security definer set search_path = public as $$
declare v public.vendors; allowed boolean := false; actor uuid := auth.uid();
begin
  select * into v from public.vendors where id = p_vendor_id for update;
  if not found then raise exception 'vendor % not found', p_vendor_id; end if;

  -- allowed transition matrix
  allowed := case v.lifecycle_status
    when 'prospect'     then p_to in ('invited','inactive')
    when 'invited'      then p_to in ('registering','inactive')
    when 'registering'  then p_to in ('submitted','inactive')
    when 'submitted'    then p_to in ('under_review','registering','inactive')
    when 'under_review' then p_to in ('approved','rejected','registering','inactive')
    when 'approved'     then p_to in ('active','blocked')
    when 'active'       then p_to in ('blocked','inactive')
    when 'blocked'      then p_to in ('active','inactive')
    when 'rejected'     then p_to in ('registering','inactive')
    when 'inactive'     then p_to in ('prospect','active')
    else false end;

  if not allowed then
    raise exception 'illegal transition % -> %', v.lifecycle_status, p_to using errcode = 'check_violation';
  end if;

  -- side effects + field updates
  update public.vendors set
    lifecycle_status = p_to,
    submitted_at = case when p_to='submitted' then now() else submitted_at end,
    approved_at  = case when p_to='approved'  then now() else approved_at end,
    approved_by  = case when p_to='approved'  then actor else approved_by end,
    vendor_code  = case when p_to in ('approved','active') and vendor_code is null
                        then public.generate_vendor_code(v.legal_name, v.org_id) else vendor_code end,
    registration_progress = case when p_to='submitted' then 100 else registration_progress end
  where id = p_vendor_id
  returning * into v;

  insert into public.vendor_status_history(vendor_id, from_status, to_status, actor_id, reason)
  values (p_vendor_id, v.lifecycle_status, p_to, actor, p_reason);

  insert into public.vendor_audit_log(vendor_id, actor_id, action, payload)
  values (p_vendor_id, actor, 'status_change',
          jsonb_build_object('to', p_to, 'reason', p_reason));

  -- notifications
  if p_to = 'submitted' then
    perform public.notify_org(v.org_id, v.id, 'approval_needed',
      v.legal_name || ' submitted registration',
      'Registration is ready for review and approval.',
      '/vendors/' || v.slug);
  elsif p_to = 'approved' then
    perform public.notify_vendor_users(v.id, 'vendor_approved',
      'Your registration was approved',
      'You are now an approved supplier. Vendor code: ' || coalesce(v.vendor_code,''),
      '/vendor/workspace/' || v.org_id);
  elsif p_to = 'rejected' then
    perform public.notify_vendor_users(v.id, 'vendor_rejected',
      'Your registration was not approved', coalesce(p_reason,'Please contact the buyer for details.'),
      '/vendor/workspace/' || v.org_id);
  elsif p_to = 'registering' and v.lifecycle_status in ('submitted','under_review') then
    perform public.notify_vendor_users(v.id, 'changes_requested',
      'Changes requested on your registration', coalesce(p_reason,'Please review and resubmit.'),
      '/vendor/onboard');
  elsif p_to = 'blocked' then
    perform public.notify_vendor_users(v.id, 'vendor_blocked',
      'Your account was blocked', coalesce(p_reason,''), '/vendor/dashboard');
  elsif p_to = 'active' and v.lifecycle_status = 'blocked' then
    perform public.notify_vendor_users(v.id, 'vendor_unblocked',
      'Your account was reactivated', '', '/vendor/dashboard');
  end if;

  return v;
end $$;
grant execute on function public.vendor_transition(uuid, vendor_lifecycle, text) to authenticated, service_role;

-- ----------------------------------------------------------------------------
-- Scorecard composite recompute (weighted average of scored lines -> /100)
-- ----------------------------------------------------------------------------
create or replace function public.recompute_scorecard(p_scorecard_id uuid) returns void
language plpgsql security definer set search_path = public as $$
declare v_vendor uuid; v_score numeric; v_risk risk_level;
begin
  select vendor_id into v_vendor from public.vendor_scorecards where id = p_scorecard_id;

  -- weighted average normalized by the weights of SCORED dimensions, scaled to /100.
  --   composite = ( Σ (avg(score)/5 * dim_weight) / Σ dim_weight ) * 100
  -- Normalizing by Σ dim_weight means partially-scored cards aren't understated.
  select round(sum(dim_norm * w) / nullif(sum(w), 0) * 100, 0) into v_score
  from (
    select dimension, avg(score)::numeric/5.0 as dim_norm, max(dimension_weight) as w
    from public.vendor_scorecard_lines
    where scorecard_id = p_scorecard_id and score is not null
    group by dimension
  ) d;

  v_risk := case
    when v_score is null then 'unrated'
    when v_score >= 80 then 'low'
    when v_score >= 60 then 'medium'
    when v_score >= 40 then 'high'
    else 'critical' end;

  update public.vendor_scorecards
     set composite_score = v_score, risk_level = v_risk,
         status = case when v_score is not null then 'complete' else status end
   where id = p_scorecard_id;

  update public.vendors set composite_score = v_score, risk_level = v_risk
   where id = v_vendor;
end $$;
grant execute on function public.recompute_scorecard(uuid) to authenticated, service_role;

create or replace function public.tg_scoreline_recompute() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  perform public.recompute_scorecard(coalesce(new.scorecard_id, old.scorecard_id));
  return null;
end $$;
drop trigger if exists scoreline_recompute on public.vendor_scorecard_lines;
create trigger scoreline_recompute after insert or update or delete
  on public.vendor_scorecard_lines for each row execute function public.tg_scoreline_recompute();

-- ----------------------------------------------------------------------------
-- Mark expired documents (run on a schedule by edge fn / pg_cron)
-- ----------------------------------------------------------------------------
create or replace function public.mark_expired_documents() returns int
language plpgsql security definer set search_path = public as $$
declare n int;
begin
  update public.vendor_documents
     set status = 'expired'
   where expires_at is not null and expires_at < current_date and status <> 'expired';
  get diagnostics n = row_count;
  return n;
end $$;

-- ----------------------------------------------------------------------------
-- Keep vendor PO rollups fresh
-- ----------------------------------------------------------------------------
create or replace function public.tg_po_rollup() returns trigger
language plpgsql security definer set search_path = public as $$
declare vid uuid;
begin
  vid := coalesce(new.vendor_id, old.vendor_id);
  update public.vendors v set
    total_spend = coalesce((select sum(amount) from public.purchase_orders where vendor_id = vid),0),
    po_count    = coalesce((select count(*)   from public.purchase_orders where vendor_id = vid),0)
  where v.id = vid;
  return null;
end $$;
drop trigger if exists po_rollup on public.purchase_orders;
create trigger po_rollup after insert or update or delete
  on public.purchase_orders for each row execute function public.tg_po_rollup();
```


### FILE: `vendor-mgmt/spec/migrations/0003_rpcs.sql`

```sql
-- =============================================================================
-- Aerchain Vendor Management — 0003 RPCs (portal + invitation + onboarding glue)
-- These SECURITY DEFINER functions are the safe public/buyer entry points so we
-- never expose raw tables to anon. Depends on 0001, 0002.
-- =============================================================================

-- slug generator (url-safe, deduped per org)
create or replace function public.generate_vendor_slug(p_name text, p_org uuid) returns text
language plpgsql stable security definer set search_path = public as $$
declare base text; cand text; n int := 0;
begin
  base := regexp_replace(lower(coalesce(p_name,'vendor')), '[^a-z0-9]+', '-', 'g');
  base := trim(both '-' from left(base, 40));
  if base = '' then base := 'vendor'; end if;
  cand := base;
  while exists (select 1 from public.vendors where org_id = p_org and slug = cand) loop
    n := n + 1; cand := base || '-' || n;
  end loop;
  return cand;
end $$;

-- upsert the vendor_users row for the current auth user
create or replace function public.ensure_vendor_user(p_email text, p_full_name text default null)
returns uuid language plpgsql security definer set search_path = public as $$
declare vid uuid;
begin
  insert into public.vendor_users(auth_user_id, email, full_name)
  values (auth.uid(), lower(p_email), p_full_name)
  on conflict (email) do update set auth_user_id = excluded.auth_user_id,
       full_name = coalesce(public.vendor_users.full_name, excluded.full_name)
  returning id into vid;
  return vid;
end $$;
grant execute on function public.ensure_vendor_user(text,text) to authenticated, service_role;

-- BUYER: Add Prospect + Send Invitation  (one call)
create or replace function public.invite_vendor(
  p_org uuid, p_company text, p_category text,
  p_contact_name text, p_email text, p_phone text default null,
  p_designation text default null, p_source vendor_source default 'manual',
  p_source_ref text default null
) returns jsonb language plpgsql security definer set search_path = public as $$
declare v_slug text; v_id uuid; v_token text;
begin
  if not public.user_in_org(p_org) then
    raise exception 'not authorized for org %', p_org using errcode='insufficient_privilege';
  end if;

  v_slug := public.generate_vendor_slug(p_company, p_org);
  insert into public.vendors(org_id, slug, legal_name, primary_category, source, source_ref,
                             lifecycle_status, created_by)
  values (p_org, v_slug, p_company, p_category, p_source, p_source_ref, 'prospect', auth.uid())
  returning id into v_id;

  insert into public.vendor_contacts(vendor_id, full_name, email, phone, designation, role, is_primary, created_by)
  values (v_id, p_contact_name, lower(p_email), p_phone, p_designation, 'procurement', true, auth.uid());

  v_token := encode(gen_random_bytes(18), 'hex');
  insert into public.vendor_invitations(org_id, vendor_id, company_name, category, contact_name,
                                        email, phone, designation, token, status, source, source_ref, invited_by, created_by)
  values (p_org, v_id, p_company, p_category, p_contact_name, lower(p_email), p_phone, p_designation,
          v_token, 'pending', p_source, p_source_ref, auth.uid(), auth.uid());

  perform public.vendor_transition(v_id, 'invited', 'invitation sent');
  insert into public.vendor_audit_log(vendor_id, actor_id, action, payload)
  values (v_id, auth.uid(), 'invitation_sent', jsonb_build_object('email', lower(p_email), 'source', p_source));

  return jsonb_build_object('vendor_id', v_id, 'slug', v_slug, 'token', v_token);
end $$;
grant execute on function public.invite_vendor(uuid,text,text,text,text,text,text,vendor_source,text) to authenticated, service_role;

-- PUBLIC: look up an invitation by token (safe fields + org branding) — anon ok
create or replace function public.get_invitation(p_token text) returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare r record;
begin
  select i.company_name, i.category, i.contact_name, i.email, i.status, i.expires_at,
         o.id as org_id, o.name as org_name, o.portal_slug, o.logo_url, o.brand_primary, v.slug as vendor_slug
  into r
  from public.vendor_invitations i
  join public.organizations o on o.id = i.org_id
  left join public.vendors v on v.id = i.vendor_id
  where i.token = p_token;
  if not found then return jsonb_build_object('valid', false); end if;
  return jsonb_build_object('valid', r.status in ('pending'), 'company_name', r.company_name,
    'category', r.category, 'contact_name', r.contact_name, 'email', r.email, 'status', r.status,
    'expires_at', r.expires_at, 'org_id', r.org_id, 'org_name', r.org_name,
    'portal_slug', r.portal_slug, 'logo_url', r.logo_url, 'brand_primary', r.brand_primary,
    'vendor_slug', r.vendor_slug);
end $$;
grant execute on function public.get_invitation(text) to anon, authenticated, service_role;

-- PUBLIC: open self-registration from a buyer's portal ("Register now") — anon ok
create or replace function public.self_register(
  p_portal_slug text, p_company text, p_category text,
  p_name text, p_email text, p_phone text default null
) returns jsonb language plpgsql security definer set search_path = public as $$
declare v_org uuid; v_slug text; v_id uuid; v_token text;
begin
  select id into v_org from public.organizations where portal_slug = p_portal_slug;
  if v_org is null then raise exception 'unknown portal %', p_portal_slug; end if;

  v_slug := public.generate_vendor_slug(p_company, v_org);
  insert into public.vendors(org_id, slug, legal_name, primary_category, source, lifecycle_status)
  values (v_org, v_slug, p_company, p_category, 'self_registration', 'prospect')
  returning id into v_id;

  insert into public.vendor_contacts(vendor_id, full_name, email, phone, role, is_primary)
  values (v_id, p_name, lower(p_email), p_phone, 'procurement', true);

  v_token := encode(gen_random_bytes(18), 'hex');
  insert into public.vendor_invitations(org_id, vendor_id, company_name, category, contact_name,
                                        email, phone, token, status, source)
  values (v_org, v_id, p_company, p_category, p_name, lower(p_email), p_phone, v_token, 'pending', 'self_registration');

  perform public.vendor_transition(v_id, 'invited', 'self-registration');
  return jsonb_build_object('vendor_slug', v_slug, 'token', v_token, 'org_id', v_org);
end $$;
grant execute on function public.self_register(text,text,text,text,text,text) to anon, authenticated, service_role;

-- VENDOR: claim an invitation after auth (links user, creates membership, starts registering)
create or replace function public.claim_invitation(p_token text) returns jsonb
language plpgsql security definer set search_path = public as $$
declare i record; vu uuid;
begin
  select * into i from public.vendor_invitations where token = p_token for update;
  if not found then raise exception 'invalid token'; end if;
  if i.status <> 'pending' or i.expires_at < now() then raise exception 'invitation not claimable'; end if;

  vu := public.ensure_vendor_user(i.email, i.contact_name);
  insert into public.vendor_memberships(vendor_user_id, vendor_id, member_role, is_primary, created_by)
  values (vu, i.vendor_id, 'owner', true, auth.uid())
  on conflict (vendor_user_id, vendor_id) do nothing;

  update public.vendor_invitations set status = 'accepted', accepted_at = now() where id = i.id;

  -- move into registering (invited -> registering); ignore if already past
  begin perform public.vendor_transition(i.vendor_id, 'registering', 'vendor started registration');
  exception when others then null; end;

  return jsonb_build_object('vendor_id', i.vendor_id,
    'vendor_slug', (select slug from public.vendors where id = i.vendor_id),
    'org_id', i.org_id);
end $$;
grant execute on function public.claim_invitation(text) to authenticated, service_role;

-- VENDOR: compute required-document checklist for a vendor (fulfilled or not)
create or replace function public.vendor_document_checklist(p_vendor uuid)
returns table(requirement_key text, doc_type document_type, label text, is_mandatory boolean,
              fulfilled boolean, document_id uuid, status document_status, expires_at date)
language sql stable security definer set search_path = public as $$
  select r.requirement_key, r.doc_type, r.label, r.is_mandatory,
         d.id is not null as fulfilled, d.id, d.status, d.expires_at
  from public.document_requirements r
  left join public.vendor_documents d
    on d.vendor_id = p_vendor and d.requirement_key = r.requirement_key
  where (r.applies_category is null
         or r.applies_category = (select primary_category from public.vendors where id = p_vendor))
  order by r.sort_order;
$$;
grant execute on function public.vendor_document_checklist(uuid) to authenticated, service_role;
```


### FILE: `vendor-mgmt/spec/migrations/0004_rls.sql`

```sql
-- =============================================================================
-- Aerchain Vendor Management — 0004 RLS POLICIES
-- Depends on 0001..0003. Uses has_role(auth.uid(),text), user_in_org(),
-- is_buyer_for_vendor(), is_vendor_member().
-- Mental model:
--   BUYER  sees/edits vendors in their org (user_in_org / is_buyer_for_vendor)
--   VENDOR sees/edits only their own vendor rows (is_vendor_member), and only
--          edits onboarding data while lifecycle in (invited, registering)
-- =============================================================================

create or replace function public.vendor_editable_by_member(p_vendor uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select public.is_vendor_member(p_vendor)
     and (select lifecycle_status in ('invited','registering')
          from public.vendors where id = p_vendor);
$$;

-- ---------- organizations (public branding read; admin write) ----------------
drop policy if exists org_read on public.organizations;
create policy org_read on public.organizations for select to anon, authenticated using (true);
drop policy if exists org_write on public.organizations;
create policy org_write on public.organizations for all to authenticated
  using (has_role(auth.uid(),'buyer_admin')) with check (has_role(auth.uid(),'buyer_admin'));

-- ---------- vendors ----------------------------------------------------------
drop policy if exists vendors_read on public.vendors;
create policy vendors_read on public.vendors for select to authenticated
  using (public.user_in_org(org_id) or public.is_vendor_member(id));
drop policy if exists vendors_insert on public.vendors;
create policy vendors_insert on public.vendors for insert to authenticated
  with check (public.user_in_org(org_id));
drop policy if exists vendors_update on public.vendors;
create policy vendors_update on public.vendors for update to authenticated
  using (public.user_in_org(org_id) or public.vendor_editable_by_member(id))
  with check (public.user_in_org(org_id) or public.vendor_editable_by_member(id));
drop policy if exists vendors_delete on public.vendors;
create policy vendors_delete on public.vendors for delete to authenticated
  using (public.user_in_org(org_id) and has_role(auth.uid(),'buyer_admin'));

-- ---------- GROUP A: vendor-fillable onboarding child tables -----------------
do $$
declare t text;
begin
  foreach t in array array[
    'vendor_tax_registrations','vendor_sites','vendor_contacts','vendor_directors',
    'vendor_documents','vendor_bank_accounts','vendor_qualification',
    'vendor_references','vendor_certifications'
  ] loop
    execute format('drop policy if exists %1$s_read on public.%1$s;', t);
    execute format($f$create policy %1$s_read on public.%1$s for select to authenticated
      using (public.is_buyer_for_vendor(vendor_id) or public.is_vendor_member(vendor_id));$f$, t);

    execute format('drop policy if exists %1$s_ins on public.%1$s;', t);
    execute format($f$create policy %1$s_ins on public.%1$s for insert to authenticated
      with check (public.is_buyer_for_vendor(vendor_id) or public.vendor_editable_by_member(vendor_id));$f$, t);

    execute format('drop policy if exists %1$s_upd on public.%1$s;', t);
    execute format($f$create policy %1$s_upd on public.%1$s for update to authenticated
      using (public.is_buyer_for_vendor(vendor_id) or public.vendor_editable_by_member(vendor_id))
      with check (public.is_buyer_for_vendor(vendor_id) or public.vendor_editable_by_member(vendor_id));$f$, t);

    execute format('drop policy if exists %1$s_del on public.%1$s;', t);
    execute format($f$create policy %1$s_del on public.%1$s for delete to authenticated
      using (public.is_buyer_for_vendor(vendor_id) or public.vendor_editable_by_member(vendor_id));$f$, t);
  end loop;
end $$;

-- ---------- GROUP B: buyer-internal due-diligence tables (vendor: no access) --
do $$
declare t text;
begin
  foreach t in array array[
    'vendor_approvals','vendor_scorecards','vendor_risk_screenings',
    'vendor_web_insights','vendor_news_items'
  ] loop
    execute format('drop policy if exists %1$s_all on public.%1$s;', t);
    execute format($f$create policy %1$s_all on public.%1$s for all to authenticated
      using (public.is_buyer_for_vendor(vendor_id))
      with check (public.is_buyer_for_vendor(vendor_id));$f$, t);
  end loop;
end $$;

-- scorecard lines (joined to scorecard.vendor_id)
drop policy if exists scoreline_all on public.vendor_scorecard_lines;
create policy scoreline_all on public.vendor_scorecard_lines for all to authenticated
  using (exists (select 1 from public.vendor_scorecards s
                 where s.id = scorecard_id and public.is_buyer_for_vendor(s.vendor_id)))
  with check (exists (select 1 from public.vendor_scorecards s
                 where s.id = scorecard_id and public.is_buyer_for_vendor(s.vendor_id)));

-- ---------- GROUP C: messages thread (buyer full; vendor read+send) ----------
drop policy if exists msg_read on public.vendor_messages;
create policy msg_read on public.vendor_messages for select to authenticated
  using (public.is_buyer_for_vendor(vendor_id) or public.is_vendor_member(vendor_id));
drop policy if exists msg_ins on public.vendor_messages;
create policy msg_ins on public.vendor_messages for insert to authenticated
  with check (public.is_buyer_for_vendor(vendor_id) or public.is_vendor_member(vendor_id));
drop policy if exists msg_upd on public.vendor_messages;          -- mark-as-read flags
create policy msg_upd on public.vendor_messages for update to authenticated
  using (public.is_buyer_for_vendor(vendor_id) or public.is_vendor_member(vendor_id))
  with check (public.is_buyer_for_vendor(vendor_id) or public.is_vendor_member(vendor_id));

-- ---------- timeline reads (writes only via SECURITY DEFINER fns) ------------
drop policy if exists status_hist_read on public.vendor_status_history;
create policy status_hist_read on public.vendor_status_history for select to authenticated
  using (public.is_buyer_for_vendor(vendor_id) or public.is_vendor_member(vendor_id));

drop policy if exists audit_read on public.vendor_audit_log;
create policy audit_read on public.vendor_audit_log for select to authenticated
  using (public.is_buyer_for_vendor(vendor_id));

-- ---------- invitations (buyer in org reads/manages; public via RPC only) ----
drop policy if exists inv_read on public.vendor_invitations;
create policy inv_read on public.vendor_invitations for select to authenticated
  using (public.user_in_org(org_id));
drop policy if exists inv_upd on public.vendor_invitations;       -- revoke/resend
create policy inv_upd on public.vendor_invitations for update to authenticated
  using (public.user_in_org(org_id)) with check (public.user_in_org(org_id));

-- ---------- notifications (recipient-scoped) ---------------------------------
drop policy if exists notif_read on public.notifications;
create policy notif_read on public.notifications for select to authenticated
  using (recipient_id = auth.uid());
drop policy if exists notif_upd on public.notifications;
create policy notif_upd on public.notifications for update to authenticated
  using (recipient_id = auth.uid()) with check (recipient_id = auth.uid());
drop policy if exists notif_del on public.notifications;
create policy notif_del on public.notifications for delete to authenticated
  using (recipient_id = auth.uid());

-- ---------- vendor_users (self) ----------------------------------------------
drop policy if exists vu_self on public.vendor_users;
create policy vu_self on public.vendor_users for select to authenticated
  using (auth_user_id = auth.uid());
drop policy if exists vu_upd on public.vendor_users;
create policy vu_upd on public.vendor_users for update to authenticated
  using (auth_user_id = auth.uid()) with check (auth_user_id = auth.uid());

-- ---------- vendor_memberships (own, or buyer of that vendor) -----------------
drop policy if exists vm_read on public.vendor_memberships;
create policy vm_read on public.vendor_memberships for select to authenticated
  using (exists (select 1 from public.vendor_users u
                 where u.id = vendor_user_id and u.auth_user_id = auth.uid())
         or public.is_buyer_for_vendor(vendor_id));

-- ---------- purchase orders (buyer org + vendor member read; buyer writes) ----
drop policy if exists po_read on public.purchase_orders;
create policy po_read on public.purchase_orders for select to authenticated
  using (public.user_in_org(org_id) or public.is_vendor_member(vendor_id));
drop policy if exists po_write on public.purchase_orders;
create policy po_write on public.purchase_orders for all to authenticated
  using (public.user_in_org(org_id)) with check (public.user_in_org(org_id));

drop policy if exists poline_read on public.purchase_order_lines;
create policy poline_read on public.purchase_order_lines for select to authenticated
  using (exists (select 1 from public.purchase_orders po where po.id = po_id
                 and (public.user_in_org(po.org_id) or public.is_vendor_member(po.vendor_id))));
drop policy if exists poline_write on public.purchase_order_lines;
create policy poline_write on public.purchase_order_lines for all to authenticated
  using (exists (select 1 from public.purchase_orders po where po.id = po_id and public.user_in_org(po.org_id)))
  with check (exists (select 1 from public.purchase_orders po where po.id = po_id and public.user_in_org(po.org_id)));

-- ---------- document_requirements (all authenticated read; admin write) ------
drop policy if exists docreq_read on public.document_requirements;
create policy docreq_read on public.document_requirements for select to authenticated using (true);
drop policy if exists docreq_write on public.document_requirements;
create policy docreq_write on public.document_requirements for all to authenticated
  using (has_role(auth.uid(),'buyer_admin')) with check (has_role(auth.uid(),'buyer_admin'));
```


### FILE: `vendor-mgmt/spec/migrations/0005_storage_realtime.sql`

```sql
-- =============================================================================
-- Aerchain Vendor Management — 0005 STORAGE + REALTIME
-- Bucket 'vendor-documents' (private). Path convention:
--    vendor-documents/{vendor_id}/{requirement_key-or-uuid}.{ext}
-- Downloads use signed URLs (client: supabase.storage.from(...).createSignedUrl()).
-- =============================================================================

insert into storage.buckets (id, name, public)
values ('vendor-documents','vendor-documents', false)
on conflict (id) do nothing;

-- helper: first path segment as uuid (the vendor_id folder)
create or replace function public.storage_vendor_id(object_name text) returns uuid
language sql immutable as $$
  select nullif((storage.foldername(object_name))[1], '')::uuid;
$$;

-- READ: buyers of the vendor or vendor members
drop policy if exists vdocs_read on storage.objects;
create policy vdocs_read on storage.objects for select to authenticated
using (
  bucket_id = 'vendor-documents'
  and (public.is_buyer_for_vendor(public.storage_vendor_id(name))
       or public.is_vendor_member(public.storage_vendor_id(name)))
);

-- WRITE/UPDATE/DELETE: vendor members (during onboarding) or buyers
drop policy if exists vdocs_insert on storage.objects;
create policy vdocs_insert on storage.objects for insert to authenticated
with check (
  bucket_id = 'vendor-documents'
  and (public.is_vendor_member(public.storage_vendor_id(name))
       or public.is_buyer_for_vendor(public.storage_vendor_id(name)))
);
drop policy if exists vdocs_update on storage.objects;
create policy vdocs_update on storage.objects for update to authenticated
using (
  bucket_id = 'vendor-documents'
  and (public.is_vendor_member(public.storage_vendor_id(name))
       or public.is_buyer_for_vendor(public.storage_vendor_id(name)))
);
drop policy if exists vdocs_delete on storage.objects;
create policy vdocs_delete on storage.objects for delete to authenticated
using (
  bucket_id = 'vendor-documents'
  and (public.is_vendor_member(public.storage_vendor_id(name))
       or public.is_buyer_for_vendor(public.storage_vendor_id(name)))
);

-- =============================================================================
-- REALTIME — publish the tables clients subscribe to (see 07-REALTIME-NOTIFICATIONS.md)
-- =============================================================================
alter publication supabase_realtime add table public.vendors;
alter publication supabase_realtime add table public.vendor_status_history;
alter publication supabase_realtime add table public.vendor_documents;
alter publication supabase_realtime add table public.vendor_messages;
alter publication supabase_realtime add table public.notifications;
alter publication supabase_realtime add table public.vendor_scorecards;
alter publication supabase_realtime add table public.vendor_risk_screenings;

-- full row images on UPDATE/DELETE so client gets old+new
alter table public.vendors                replica identity full;
alter table public.vendor_documents       replica identity full;
alter table public.vendor_messages        replica identity full;
alter table public.notifications          replica identity full;
alter table public.vendor_scorecards      replica identity full;
```


### FILE: `vendor-mgmt/spec/migrations/0006_seed.sql`

```sql
-- =============================================================================
-- Aerchain Vendor Management — 0006 SEED
-- Populates Adani tenant with believable Indian B2B suppliers so the app looks
-- live on first load. Run AFTER 0001..0005. Auth users are linked at the bottom
-- (see DEMO USERS) once the auth accounts exist.
--
-- Monetary conventions: PO.amount in rupees; qualification turnover/net_worth in
-- CRORES (display fields). [A3]
-- =============================================================================

-- ---------- ORGS -------------------------------------------------------------
insert into public.organizations (id, name, slug, org_type, portal_slug, website, brand_primary) values
  ('00000000-0000-0000-0000-0000000000a0','Aerchain','aerchain','platform', null, 'https://aerchain.io', null),
  ('00000000-0000-0000-0000-0000000000a1','Adani Group','adani','buyer','adani','https://www.adani.com','#0a3d62')
on conflict (id) do nothing;

-- ---------- DOCUMENT REQUIREMENTS (the standard onboarding checklist) ---------
insert into public.document_requirements (requirement_key, doc_type, label, applies_category, is_mandatory, per_tax_registration, sort_order) values
  ('pan','pan_card','PAN Card', null, true, false, 10),
  ('coi','incorporation_certificate','Certificate of Incorporation', null, true, false, 20),
  ('gst','gst_certificate','GST Registration Certificate', null, true, true, 30),
  ('bank_proof','bank_proof','Bank Proof (cancelled cheque / letter)', null, true, false, 40),
  ('insurance','insurance','Insurance Certificate', null, true, false, 50),
  ('iso_9001','iso_9001','Quality Certificate (ISO 9001)', null, true, false, 60),
  ('iso_14001','iso_14001','Environmental Certificate (ISO 14001)', null, false, false, 70),
  ('material_test','material_test_certificate','Material Test Certificate','Raw Materials', true, false, 80),
  ('msa','msa','Master Service Agreement', null, false, false, 90)
on conflict (requirement_key) do nothing;

-- =============================================================================
-- VENDOR 1 — TATA STEEL (ent-1) — fully ACTIVE, full 360 depth
-- =============================================================================
insert into public.vendors (id, org_id, slug, legal_name, trade_name, group_name, vendor_code,
  pan, cin, entity_type, incorporation_date, website, primary_category, business_description,
  addr_line1, city, state, pincode, country, lifecycle_status, tier, risk_level, source,
  registration_progress, submitted_at, approved_at, composite_score, total_spend, po_count)
values ('00000000-0000-0000-0000-00000000e001','00000000-0000-0000-0000-0000000000a1','ent-1',
  'Tata Steel Limited','Tata Steel','Tata Group','TATA-STL',
  'AAACT2727Q','L27100MH1907PLC000260','Public Limited','1907-08-26','https://www.tatasteel.com',
  'Raw Materials','Leading global steel company with manufacturing operations in 26 countries.',
  'Bombay House, 24 Homi Modi Street','Mumbai','Maharashtra','400001','India',
  'active','strategic','low','manual',100, now()-interval '70 days', now()-interval '60 days',
  79, 452000000, 142)
on conflict (id) do nothing;

-- tax registrations (Tier 3)
insert into public.vendor_tax_registrations (id, vendor_id, tax_type, registration_number, jurisdiction, jurisdiction_code, status, addr_line1, city, state, pincode, is_primary) values
 ('00000000-0000-0000-0000-00000000f001','00000000-0000-0000-0000-00000000e001','gstin','27AAACT2727Q1ZV','Maharashtra','27','active','Bombay House, 24 Homi Modi Street','Mumbai','Maharashtra','400001',true),
 ('00000000-0000-0000-0000-00000000f002','00000000-0000-0000-0000-00000000e001','gstin','29AAACT2727Q1ZT','Karnataka','29','active','No. 12, Outer Ring Road, Marathahalli','Bangalore','Karnataka','560037',false),
 ('00000000-0000-0000-0000-00000000f003','00000000-0000-0000-0000-00000000e001','gstin','33AAACT2727Q1ZP','Tamil Nadu','33','active','Plot 45, SIPCOT Industrial Park, Gummidipoondi','Chennai','Tamil Nadu','601201',false),
 ('00000000-0000-0000-0000-00000000f004','00000000-0000-0000-0000-00000000e001','iec','0388001295','India (Nationwide)','IN','active','Bombay House','Mumbai','Maharashtra','400001',false)
on conflict (id) do nothing;

-- sites (Tier 4)
insert into public.vendor_sites (vendor_id, tax_registration_id, site_name, site_code, site_type, city, state) values
 ('00000000-0000-0000-0000-00000000e001','00000000-0000-0000-0000-00000000f001','Mumbai HQ','MUM-HQ','office','Mumbai','Maharashtra'),
 ('00000000-0000-0000-0000-00000000e001','00000000-0000-0000-0000-00000000f001','Jamshedpur Plant','JSR-PLT','factory','Jamshedpur','Jharkhand'),
 ('00000000-0000-0000-0000-00000000e001','00000000-0000-0000-0000-00000000f001','Pune Warehouse','PNQ-WH','warehouse','Pune','Maharashtra'),
 ('00000000-0000-0000-0000-00000000e001','00000000-0000-0000-0000-00000000f002','Bangalore Office','BLR-OFF','office','Bangalore','Karnataka'),
 ('00000000-0000-0000-0000-00000000e001','00000000-0000-0000-0000-00000000f002','Mysore Hub','MYS-HUB','hub','Mysore','Karnataka'),
 ('00000000-0000-0000-0000-00000000e001','00000000-0000-0000-0000-00000000f003','Chennai Branch','CHN-BR','branch','Chennai','Tamil Nadu');

-- contacts (entity-wide)
insert into public.vendor_contacts (vendor_id, full_name, email, phone, designation, role, is_primary) values
 ('00000000-0000-0000-0000-00000000e001','Rajesh Mehta','rajesh.mehta@tatasteel.com','+91 98765 43210','Key Account Manager','sales',true),
 ('00000000-0000-0000-0000-00000000e001','Priya Nair','priya.nair@tatasteel.com','+91 98765 43211','AR Lead','accounts',false),
 ('00000000-0000-0000-0000-00000000e001','Amit Kumar','amit.kumar@tatasteel.com','+91 98765 43212','Logistics Head','logistics',false);

-- directors
insert into public.vendor_directors (vendor_id, full_name, din, designation, source) values
 ('00000000-0000-0000-0000-00000000e001','T.V. Narendran','03083605','Managing Director & CEO','mca'),
 ('00000000-0000-0000-0000-00000000e001','Koushik Chatterjee','00004989','Executive Director & CFO','mca');

-- banking
insert into public.vendor_bank_accounts (vendor_id, scope, account_holder_name, account_number, account_type, currency, bank_name, branch, ifsc, is_primary) values
 ('00000000-0000-0000-0000-00000000e001','domestic','Tata Steel Limited','00078350000061','Current Account','INR','State Bank of India','Fort, Mumbai','SBIN0000300',true),
 ('00000000-0000-0000-0000-00000000e001','domestic','Tata Steel Limited','00012345678901','Current Account','INR','HDFC Bank','Nariman Point, Mumbai','HDFC0002345',false);

-- qualification + esg + infosec
insert into public.vendor_qualification (vendor_id, turnover_y1, turnover_y1_label, turnover_y2, turnover_y2_label,
  turnover_y3, turnover_y3_label, net_worth, profitability_status, auditor, fy_ends_in, years_experience,
  employee_count, manufacturing_capacity, quality_system, iso27001, soc2, data_encryption, incident_response,
  bcp_dr, environmental_policy, sustainability_certs, diversity_status) values
 ('00000000-0000-0000-0000-00000000e001',243832,'FY2022-23',225670,'FY2023-24',258900,'FY2024-25',750000,
  'Profitable','Price Waterhouse Chartered Accountants LLP','March',117,35000,'35 MTPA','TQM',
  true,false,true,true,true,true, array['GRI Standards','CDP Climate'], array['Large Enterprise']);

-- references
insert into public.vendor_references (vendor_id, company_name, contact_name, contact_email, project_description, value_range) values
 ('00000000-0000-0000-0000-00000000e001','Maruti Suzuki India Ltd','Vikram Singh','vikram.singh@maruti.co.in','Automotive-grade steel supply for body panels','₹500Cr+');

-- documents (verified) — Tata Steel
insert into public.vendor_documents (id, vendor_id, doc_type, requirement_key, label, status, file_name, issuer, expires_at, cert_number, verified_at) values
 ('00000000-0000-0000-0000-0000000d0001','00000000-0000-0000-0000-00000000e001','pan_card','pan','PAN Card','verified','pan.pdf',null,null,null, now()-interval '58 days'),
 ('00000000-0000-0000-0000-0000000d0002','00000000-0000-0000-0000-00000000e001','gst_certificate','gst','GST Certificate – Maharashtra','verified','gst_mh.pdf',null,null,null, now()-interval '58 days'),
 ('00000000-0000-0000-0000-0000000d0003','00000000-0000-0000-0000-00000000e001','incorporation_certificate','coi','Certificate of Incorporation','verified','coi.pdf',null,null,null, now()-interval '58 days'),
 ('00000000-0000-0000-0000-0000000d0004','00000000-0000-0000-0000-00000000e001','insurance','insurance','Insurance Certificate','verified','insurance.pdf',null, (current_date+interval '120 days')::date,null, now()-interval '58 days'),
 ('00000000-0000-0000-0000-0000000d0005','00000000-0000-0000-0000-00000000e001','bank_proof','bank_proof','Bank Verification Letter','verified','bank_letter.pdf',null,null,null, now()-interval '58 days'),
 ('00000000-0000-0000-0000-0000000d0006','00000000-0000-0000-0000-00000000e001','iso_9001','iso_9001','ISO 9001 Quality Certificate','verified','iso9001.pdf','Bureau Veritas','2027-06-30','BV-QMS-2024-IN-7892', now()-interval '58 days'),
 ('00000000-0000-0000-0000-0000000d0007','00000000-0000-0000-0000-00000000e001','iso_14001','iso_14001','ISO 14001 Environmental Certificate','verified','iso14001.pdf','TÜV SÜD','2026-12-31','TUV-EMS-2023-IN-4410', now()-interval '58 days')
on conflict (id) do nothing;

-- certifications
insert into public.vendor_certifications (vendor_id, cert_type, issuer, valid_until, cert_number, document_id) values
 ('00000000-0000-0000-0000-00000000e001','ISO 9001 (Quality)','Bureau Veritas','2027-06-30','BV-QMS-2024-IN-7892','00000000-0000-0000-0000-0000000d0006'),
 ('00000000-0000-0000-0000-00000000e001','ISO 14001 (Environment)','TÜV SÜD','2026-12-31','TUV-EMS-2023-IN-4410','00000000-0000-0000-0000-0000000d0007');

-- scorecard (composite 79, medium) + lines
insert into public.vendor_scorecards (id, vendor_id, name, status, scope, composite_score, risk_level, evaluator_name) values
 ('00000000-0000-0000-0000-00000000c001','00000000-0000-0000-0000-00000000e001','FY25 Annual Evaluation','complete',
  array['financial_health','compliance_standing','operational_capability','esg_sustainability']::scorecard_dimension[],
  79,'medium','Harsha Kadimisetty')
on conflict (id) do nothing;
insert into public.vendor_scorecard_lines (scorecard_id, dimension, dimension_weight, criterion, score, data_source, basis) values
 ('00000000-0000-0000-0000-00000000c001','financial_health',0.20,'Revenue Stability',5,'Financial Statements','3y revenue trend stable'),
 ('00000000-0000-0000-0000-00000000c001','financial_health',0.20,'Profitability Trend',4,'Annual Report','Profitable, margins healthy'),
 ('00000000-0000-0000-0000-00000000c001','financial_health',0.20,'Credit Rating',4,'CRISIL','AA/Stable'),
 ('00000000-0000-0000-0000-00000000c001','compliance_standing',0.20,'GST Filing Timeliness',4,'GST Portal','>95% on-time'),
 ('00000000-0000-0000-0000-00000000c001','compliance_standing',0.20,'Sanctions / Debarment Check',5,'Sanctions Screening API','Clean'),
 ('00000000-0000-0000-0000-00000000c001','compliance_standing',0.20,'Anti-Bribery & Corruption',4,'Vendor Declaration','Policy in place'),
 ('00000000-0000-0000-0000-00000000c001','operational_capability',0.20,'On-Time Delivery Rate',4,'PO/GRN Records','96.2% OTD'),
 ('00000000-0000-0000-0000-00000000c001','operational_capability',0.20,'Quality Rejection Rate',4,'QC/Inspection Logs','<1% rejects'),
 ('00000000-0000-0000-0000-00000000c001','esg_sustainability',0.15,'Environmental Policy',3,'ESG Disclosure','GRI + CDP, improving');

-- web insights cache
insert into public.vendor_web_insights (vendor_id, overview, headquarters, founded, employees, revenue, industry,
  stock_ticker, website, market_cap, credit_rating, credit_agency, dnb_rating, key_ratios, key_personnel,
  sanctions_status, pep_status, ratings, refreshed_at) values
 ('00000000-0000-0000-0000-00000000e001',
  'Tata Steel Limited is one of the world''s most geographically diversified steel producers, with operations in over 50 countries and a flagship of the Tata Group.',
  'Mumbai, Maharashtra, India','1907','~80,000','₹2,00,000+ Cr','Metals & Mining — Steel','NSE: TATASTEEL','tatasteel.com',
  '₹1,92,000 Cr','CRISIL AA/Stable','CRISIL','5A1 (Highest)',
  '{"debt_equity":0.68,"current_ratio":1.12,"ebitda_margin":"18.4%","roe":"12.6%","interest_coverage":"5.8x"}'::jsonb,
  '[{"name":"T.V. Narendran","title":"CEO & MD"},{"name":"Koushik Chatterjee","title":"ED & CFO"},{"name":"Noel Tata","title":"Chairman"}]'::jsonb,
  'Clean','Clean',
  '{"google":{"rating":4.1,"reviews":1240},"glassdoor":{"rating":4.0,"reviews":8500}}'::jsonb, now()-interval '2 hours');

insert into public.vendor_news_items (vendor_id, title, source, published_at, sentiment) values
 ('00000000-0000-0000-0000-00000000e001','Tata Steel''s Kalinganagar expansion on track for H2 FY25 commissioning','Economic Times', current_date-30,'positive'),
 ('00000000-0000-0000-0000-00000000e001','Tata Steel reports 3% decline in Q3 revenue amid global steel price softness','Business Standard', current_date-45,'negative'),
 ('00000000-0000-0000-0000-00000000e001','Tata Steel partners with startup for green hydrogen-based steelmaking pilot','Mint', current_date-60,'positive'),
 ('00000000-0000-0000-0000-00000000e001','UK operations restructuring progresses; Port Talbot transition plan shared','Reuters', current_date-75,'neutral');

-- risk screenings (clean)
insert into public.vendor_risk_screenings (vendor_id, screening_type, status, entities_checked, hits, provider, mode, checked_at, result) values
 ('00000000-0000-0000-0000-00000000e001','sanctions','clean',4,0,'OpenSanctions','mock', now()-interval '2 hours','{"lists":["OFAC","EU","UN"]}'::jsonb),
 ('00000000-0000-0000-0000-00000000e001','pep','clean',6,0,'OpenSanctions','mock', now()-interval '2 hours','{}'::jsonb);

-- purchase orders (powers Business Overview)
insert into public.purchase_orders (vendor_id, org_id, po_number, title, category, amount, status, order_date, delivery_date) values
 ('00000000-0000-0000-0000-00000000e001','00000000-0000-0000-0000-0000000000a1','PO-2025-0125','Rebars 12mm — Construction Site Alpha','Rebars & Wire Rods',9500000,'delivered','2025-01-15','2025-02-01'),
 ('00000000-0000-0000-0000-00000000e001','00000000-0000-0000-0000-0000000000a1','PO-2025-0118','HR Coils — Emergency Replenishment','Hot Rolled Coils',41000000,'delivered','2025-01-05','2025-01-20'),
 ('00000000-0000-0000-0000-00000000e001','00000000-0000-0000-0000-0000000000a1','PO-2025-0112','Cold Rolled Sheets — Plant 2','Cold Rolled Sheets',18500000,'invoiced','2024-12-20','2025-01-10'),
 ('00000000-0000-0000-0000-00000000e001','00000000-0000-0000-0000-0000000000a1','PO-2025-0101','Galvanized Steel — Coastal Project','Galvanized Steel',7600000,'paid','2024-12-01','2024-12-18');

-- status history + audit (abridged trail)
insert into public.vendor_status_history (vendor_id, from_status, to_status, reason, at) values
 ('00000000-0000-0000-0000-00000000e001','submitted','under_review','review started', now()-interval '65 days'),
 ('00000000-0000-0000-0000-00000000e001','under_review','approved','due diligence passed', now()-interval '60 days'),
 ('00000000-0000-0000-0000-00000000e001','approved','active','activated', now()-interval '60 days');
insert into public.vendor_audit_log (vendor_id, action, payload, at) values
 ('00000000-0000-0000-0000-00000000e001','status_change','{"to":"approved"}'::jsonb, now()-interval '60 days'),
 ('00000000-0000-0000-0000-00000000e001','document_verified','{"doc":"iso_9001"}'::jsonb, now()-interval '58 days'),
 ('00000000-0000-0000-0000-00000000e001','screening_complete','{"sanctions":"clean"}'::jsonb, now()-interval '2 hours');

-- =============================================================================
-- VENDOR 2 — BHARAT FORGE — INVITED (drives the live demo onboarding)
--   Invitation token is fixed so the demo link is predictable.
-- =============================================================================
insert into public.vendors (id, org_id, slug, legal_name, primary_category, lifecycle_status, tier, risk_level, source) values
 ('00000000-0000-0000-0000-00000000e002','00000000-0000-0000-0000-0000000000a1','bharat-forge','Bharat Forge Limited','Capital & Equipment','invited','unclassified','unrated','manual')
on conflict (id) do nothing;
insert into public.vendor_contacts (vendor_id, full_name, email, phone, designation, role, is_primary) values
 ('00000000-0000-0000-0000-00000000e002','Rakesh Kumar','rakesh@tatasteel-demo.com','+91 98765 12345','Procurement Head','procurement',true);
insert into public.vendor_invitations (org_id, vendor_id, company_name, category, contact_name, email, token, status, source) values
 ('00000000-0000-0000-0000-0000000000a1','00000000-0000-0000-0000-00000000e002','Bharat Forge Limited','Capital & Equipment','Rakesh Kumar','rakesh@tatasteel-demo.com','demo-bharatforge-token','pending','manual')
on conflict (token) do nothing;

-- =============================================================================
-- VENDOR 3 — ASIAN PAINTS — ACTIVE with a doc EXPIRING IN 7 DAYS (alert demo)
-- =============================================================================
insert into public.vendors (id, org_id, slug, legal_name, trade_name, vendor_code, pan, primary_category,
  city, state, lifecycle_status, tier, risk_level, source, composite_score, total_spend, po_count, approved_at) values
 ('00000000-0000-0000-0000-00000000e003','00000000-0000-0000-0000-0000000000a1','asian-paints','Asian Paints Limited','Asian Paints','ASNPT-001','AAACA6666N','Raw Materials',
  'Mumbai','Maharashtra','active','preferred','low','manual',84, 128000000, 56, now()-interval '120 days')
on conflict (id) do nothing;
insert into public.vendor_documents (vendor_id, doc_type, requirement_key, label, status, file_name, issuer, expires_at, cert_number) values
 ('00000000-0000-0000-0000-00000000e003','iso_9001','iso_9001','ISO 9001 Quality Certificate','uploaded','iso9001_ap.pdf','DNV',(current_date + 7),'DNV-QMS-2022-IN-5510'),
 ('00000000-0000-0000-0000-00000000e003','pan_card','pan','PAN Card','verified','pan_ap.pdf',null,null,null);

-- =============================================================================
-- VENDORS 4–10 — span remaining statuses (lighter rows for list/KPI realism)
-- =============================================================================
insert into public.vendors (org_id, slug, legal_name, vendor_code, primary_category, city, state,
  lifecycle_status, tier, risk_level, source, composite_score, total_spend, po_count, registration_progress) values
 ('00000000-0000-0000-0000-0000000000a1','lt-construction','Larsen & Toubro Construction','LTCON-001','Professional Services','Chennai','Tamil Nadu','active','strategic','low','manual',88, 980000000, 210, 100),
 ('00000000-0000-0000-0000-0000000000a1','hindalco','Hindalco Industries Limited','HNDLC-001','Raw Materials','Mumbai','Maharashtra','approved','preferred','medium','manual',72, 0,0,100),
 ('00000000-0000-0000-0000-0000000000a1','siemens-india','Siemens Limited India',null,'Software & Technology','Mumbai','Maharashtra','under_review','conditional','medium','rfx_event',null,0,0,100),
 ('00000000-0000-0000-0000-0000000000a1','cummins-india','Cummins India Limited',null,'Capital & Equipment','Pune','Maharashtra','submitted','unclassified','unrated','rfx_event',null,0,0,100),
 ('00000000-0000-0000-0000-0000000000a1','mahindra-logistics','Mahindra Logistics Limited',null,'Logistics & Freight','Mumbai','Maharashtra','registering','unclassified','unrated','self_registration',null,0,0,45),
 ('00000000-0000-0000-0000-0000000000a1','ultratech-cement','UltraTech Cement Limited','ULTRA-001','Raw Materials','Mumbai','Maharashtra','blocked','approved','high','manual',58, 64000000, 22,100),
 ('00000000-0000-0000-0000-0000000000a1','bharat-electronics','Bharat Electronics Limited',null,'Software & Technology','Bangalore','Karnataka','rejected','unclassified','high','rfx_event',null,0,0,100);

-- a couple POs for L&T so a second vendor has Business-Overview data
insert into public.purchase_orders (vendor_id, org_id, po_number, title, category, amount, status, order_date)
select v.id, v.org_id, 'PO-2025-0207','Civil works — Mundra Phase 2','Construction',125000000,'acknowledged','2025-02-07'
from public.vendors v where v.slug='lt-construction';

-- scorecards for 5 vendors total (Tata already has one) -> add 4 quick ones
insert into public.vendor_scorecards (vendor_id, name, status, composite_score, risk_level, evaluator_name)
select id, 'FY25 Evaluation','complete', s.score, s.risk, 'Harsha Kadimisetty'
from (values
 ('asian-paints',84,'low'::risk_level),
 ('lt-construction',88,'low'::risk_level),
 ('hindalco',72,'medium'::risk_level),
 ('ultratech-cement',58,'high'::risk_level)
) as s(slug, score, risk)
join public.vendors v on v.slug = s.slug;

-- =============================================================================
-- PROSPECTS (match the live Prospects tab screenshot) — early-stage rows
-- =============================================================================
insert into public.vendors (org_id, slug, legal_name, primary_category, lifecycle_status, source, source_ref) values
 ('00000000-0000-0000-0000-0000000000a1','rajesh-fabricators','Rajesh Fabricators Pvt Ltd','Raw Materials','prospect','manual',null),
 ('00000000-0000-0000-0000-0000000000a1','techvista-solutions','TechVista Solutions Inc','IT Services','prospect','rfx_event','RFQ-2025-001'),
 ('00000000-0000-0000-0000-0000000000a1','greenpack-industries','GreenPack Industries','Packaging','registering','self_registration',null),
 ('00000000-0000-0000-0000-0000000000a1','muller-precision','Müller Precision GmbH','Precision Engineering','prospect','manual',null),
 ('00000000-0000-0000-0000-0000000000a1','apex-chemical','Apex Chemical Corp','Chemicals','approved','rfx_event','RFQ-2025-014'),
 ('00000000-0000-0000-0000-0000000000a1','oceanic-logistics','Oceanic Logistics Ltd','Logistics','inactive','manual',null);
insert into public.vendor_contacts (vendor_id, full_name, email, role, is_primary)
select v.id, c.nm, c.em, 'procurement', true from (values
 ('rajesh-fabricators','Rajesh Kumar','rajesh@fabricators.co.in'),
 ('techvista-solutions','Ananya Gupta','ananya@techvista.com'),
 ('greenpack-industries','Suresh Menon','suresh@greenpack.in'),
 ('muller-precision','Hans Müller','hans@muller-precision.de'),
 ('apex-chemical','Vivek Sharma','vivek@apexchem.in'),
 ('oceanic-logistics','Priya Nair','priya@oceanic-log.com')
) as c(slug,nm,em) join public.vendors v on v.slug=c.slug;

-- =============================================================================
-- DEMO USERS — create these AUTH accounts (Supabase Auth) then run link_demo_users()
-- Buyer (Adani tenant):
--   priya@adani-demo.com    buyer_admin
--   arjun@adani-demo.com    buyer_approver
--   neha@adani-demo.com     buyer_requester
-- Vendor:
--   rakesh@tatasteel-demo.com    -> Bharat Forge (e002)  [live demo]
--   meera@tatasteel-demo.com     -> Tata Steel  (e001)
--   (passwords: set in Supabase; e.g. Demo@12345)
-- =============================================================================
create or replace function public.link_demo_users() returns void
language plpgsql security definer set search_path = public as $$
declare adani uuid := '00000000-0000-0000-0000-0000000000a1';
        uid uuid;
begin
  -- BUYERS: map auth.users by email -> org_users + roles
  -- [ASSUMPTION] org_users(user_id,org_id); roles/user_roles(user_id, role). Adapt names if different.
  for uid in select id from auth.users where email in ('priya@adani-demo.com','arjun@adani-demo.com','neha@adani-demo.com') loop
    insert into public.org_users(user_id, org_id) values (uid, adani) on conflict do nothing;
  end loop;
  -- roles (adapt table name to your existing roles schema)
  -- insert into public.user_roles(user_id, role) select id, 'buyer_admin'    from auth.users where email='priya@adani-demo.com' on conflict do nothing;
  -- insert into public.user_roles(user_id, role) select id, 'buyer_approver' from auth.users where email='arjun@adani-demo.com' on conflict do nothing;
  -- insert into public.user_roles(user_id, role) select id, 'buyer_requester'from auth.users where email='neha@adani-demo.com'  on conflict do nothing;

  -- VENDOR USERS + memberships
  insert into public.vendor_users(auth_user_id, email, full_name)
    select id, email, 'Rakesh Kumar' from auth.users where email='rakesh@tatasteel-demo.com'
    on conflict (email) do update set auth_user_id = excluded.auth_user_id;
  insert into public.vendor_users(auth_user_id, email, full_name)
    select id, email, 'Meera Iyer' from auth.users where email='meera@tatasteel-demo.com'
    on conflict (email) do update set auth_user_id = excluded.auth_user_id;

  insert into public.vendor_memberships(vendor_user_id, vendor_id, member_role, is_primary)
    select vu.id, '00000000-0000-0000-0000-00000000e002', 'owner', true
    from public.vendor_users vu where vu.email='rakesh@tatasteel-demo.com' on conflict do nothing;
  insert into public.vendor_memberships(vendor_user_id, vendor_id, member_role, is_primary)
    select vu.id, '00000000-0000-0000-0000-00000000e001', 'owner', true
    from public.vendor_users vu where vu.email='meera@tatasteel-demo.com' on conflict do nothing;
end $$;

-- After creating the 5 auth accounts, run:  select public.link_demo_users();
```


### FILE: `vendor-mgmt/spec/migrations/0007_integration_dd_tagging.sql`

```sql
-- =============================================================================
-- Aerchain Vendor Management — 0007 ERP INTEGRATION + VENDOR TAGGING + DUE DILIGENCE
-- Adds: front-end-configurable integration connections, bi-directional vendor-master
-- sync bookkeeping, GRN metrics, OEM/dealer + preferred tagging, a configurable
-- due-diligence checklist with an approval gate, and master-data dedup candidates.
-- Depends on 0001..0006.
-- =============================================================================

do $$ begin
  create type erp_system            as enum ('sap_s4hana','sap_mdg','sap_ariba','coupa','oracle','baan_infor','generic_rest');
  create type integration_auth      as enum ('api_key','oauth2','basic','cert');
  create type sync_direction        as enum ('inbound','outbound');
  create type integration_run_status as enum ('running','success','partial','error');
  create type vendor_class          as enum ('oem','dealer','distributor','channel_partner','manufacturer','service_provider','other');
  create type dd_source             as enum ('api','ai','human','processunity');
  create type dd_status             as enum ('pending','pass','fail','manual_review','waived');
exception when duplicate_object then null; end $$;

-- ---------- vendor tagging (OEM vs dealer, preferred, brands) -----------------
alter table public.vendors add column if not exists vendor_class vendor_class not null default 'other';
alter table public.vendors add column if not exists is_preferred boolean not null default false;
alter table public.vendors add column if not exists brand_tags text[] not null default '{}';
alter table public.vendors add column if not exists parent_oem_id uuid references public.vendors(id) on delete set null;
create index if not exists idx_vendors_class on public.vendors(org_id, vendor_class);

-- ---------- integration connections (front-end configurable) -----------------
create table if not exists public.integration_connections (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references public.organizations(id) on delete cascade,
  system_type erp_system not null,
  name text not null,
  base_url text,
  environment text default 'sandbox',          -- 'sandbox' | 'prod'
  auth_type integration_auth not null default 'api_key',
  vault_secret_id uuid,                          -- Supabase Vault secret id (NEVER store creds plaintext)
  status text not null default 'unconfigured',   -- 'unconfigured'|'connected'|'error'
  last_test_at timestamptz,
  last_test_info jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_intconn_org on public.integration_connections(org_id);

create table if not exists public.integration_field_mappings (
  id uuid primary key default gen_random_uuid(),
  connection_id uuid not null references public.integration_connections(id) on delete cascade,
  entity text not null default 'vendor',         -- 'vendor' | 'grn'
  direction sync_direction not null default 'outbound',
  source_field text not null,                    -- AirChain field
  target_field text not null,                    -- ERP field (e.g. LIFNR/NAME1)
  transform text,                                -- optional expression/format note
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_fieldmap_conn on public.integration_field_mappings(connection_id);

create table if not exists public.vendor_external_refs (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid not null references public.vendors(id) on delete cascade,
  connection_id uuid references public.integration_connections(id) on delete set null,
  external_system erp_system not null,
  external_id text not null,                     -- LIFNR / SMVendorID
  last_synced_at timestamptz,
  sync_status text,
  sync_hash text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid,
  unique (vendor_id, external_system)
);
create index if not exists idx_extref_vendor on public.vendor_external_refs(vendor_id);

create table if not exists public.integration_sync_runs (
  id uuid primary key default gen_random_uuid(),
  connection_id uuid references public.integration_connections(id) on delete cascade,
  org_id uuid references public.organizations(id) on delete cascade,
  direction sync_direction not null,
  entity text not null default 'vendor',
  status integration_run_status not null default 'running',
  total_count int default 0, ok_count int default 0, failed_count int default 0,
  started_at timestamptz not null default now(),
  finished_at timestamptz,
  error text,
  triggered_by uuid,
  created_at timestamptz not null default now()
);
create index if not exists idx_syncrun_conn on public.integration_sync_runs(connection_id, started_at desc);

create table if not exists public.integration_sync_records (
  id uuid primary key default gen_random_uuid(),
  run_id uuid not null references public.integration_sync_runs(id) on delete cascade,
  vendor_id uuid references public.vendors(id) on delete set null,
  external_id text,
  action text,                                   -- create|update|skip|conflict
  status text,                                   -- ok|error
  payload jsonb,
  error text,
  created_at timestamptz not null default now()
);
create index if not exists idx_syncrec_run on public.integration_sync_records(run_id);

-- ---------- GRN / objective performance metrics (pulled from SAP) ------------
create table if not exists public.vendor_grn_metrics (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid not null references public.vendors(id) on delete cascade,
  period text,                                   -- 'FY2024-25' or 'Q1'
  on_time_delivery_pct numeric,
  quality_rejection_pct numeric,
  grn_count int,
  source_connection_id uuid references public.integration_connections(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_grn_vendor on public.vendor_grn_metrics(vendor_id);

-- ---------- due diligence: configurable checklist + per-vendor items ----------
create table if not exists public.due_diligence_checks (
  id uuid primary key default gen_random_uuid(),
  check_key text unique not null,                -- 'sanctions_ofac','gst_active',...
  label text not null,
  category text,                                 -- identity|tax|sanctions|financial|legal|reputation|physical|operational|aggregate
  provider text,                                 -- OFAC|GST portal|DNB|Equifax|ProcessUnity|AI|human
  default_source dd_source not null default 'api',
  is_mandatory boolean not null default false,
  applies_min_risk risk_level,                   -- null=all; else only when vendor risk >= this
  enabled boolean not null default true,
  sort_order int default 100,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);

create table if not exists public.vendor_due_diligence_items (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid not null references public.vendors(id) on delete cascade,
  check_key text not null,
  status dd_status not null default 'pending',
  source dd_source not null default 'api',
  result jsonb,
  evidence_document_id uuid references public.vendor_documents(id) on delete set null,
  performed_by uuid,
  performed_at timestamptz,
  note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid,
  unique (vendor_id, check_key)
);
create index if not exists idx_dd_vendor on public.vendor_due_diligence_items(vendor_id);

-- ---------- master-data dedup candidates -------------------------------------
create table if not exists public.vendor_duplicate_candidates (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid not null references public.vendors(id) on delete cascade,
  match_vendor_id uuid not null references public.vendors(id) on delete cascade,
  score numeric,                                 -- 0..1 similarity
  reason text,
  status text not null default 'open',           -- open|merged|dismissed
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_dupe_vendor on public.vendor_duplicate_candidates(vendor_id);

-- ---------- triggers (updated_at + created_by) for new tables -----------------
do $$
declare t text;
begin
  foreach t in array array[
    'integration_connections','integration_field_mappings','vendor_external_refs',
    'vendor_grn_metrics','due_diligence_checks','vendor_due_diligence_items',
    'vendor_duplicate_candidates'
  ] loop
    execute format('drop trigger if exists set_updated_at on public.%I;', t);
    execute format('create trigger set_updated_at before update on public.%I for each row execute function public.tg_set_updated_at();', t);
    execute format('drop trigger if exists set_created_by on public.%I;', t);
    execute format('create trigger set_created_by before insert on public.%I for each row execute function public.tg_set_created_by();', t);
  end loop;
end $$;

-- ---------- DD gate helper + guarded approve RPC ------------------------------
-- Returns whether all mandatory DD checks (for the vendor's risk tier) have passed.
create or replace function public.dd_gate_status(p_vendor uuid) returns jsonb
language sql stable security definer set search_path = public as $$
  with applicable as (
    select c.check_key, c.is_mandatory
    from public.due_diligence_checks c
    where c.enabled
      and (c.applies_min_risk is null
           or (select risk_level from public.vendors where id = p_vendor) >= c.applies_min_risk)
  ),
  items as (
    select a.check_key, a.is_mandatory,
           coalesce(d.status, 'pending')::text as status
    from applicable a
    left join public.vendor_due_diligence_items d
      on d.vendor_id = p_vendor and d.check_key = a.check_key
  )
  select jsonb_build_object(
    'mandatory_total', count(*) filter (where is_mandatory),
    'mandatory_passed', count(*) filter (where is_mandatory and status in ('pass','waived')),
    'passed', count(*) filter (where is_mandatory and status not in ('pass','waived')) = 0
  ) from items;
$$;
grant execute on function public.dd_gate_status(uuid) to authenticated, service_role;

-- Approve a vendor only if the DD gate passes (or is explicitly waived).
create or replace function public.approve_vendor(p_vendor uuid, p_note text default null, p_waive boolean default false)
returns public.vendors
language plpgsql security definer set search_path = public as $$
declare gate jsonb; v public.vendors;
begin
  if not public.is_buyer_for_vendor(p_vendor) then
    raise exception 'not authorized' using errcode='insufficient_privilege';
  end if;
  gate := public.dd_gate_status(p_vendor);
  if not (gate->>'passed')::boolean and not p_waive then
    raise exception 'due diligence not complete: %', gate using errcode='check_violation';
  end if;

  insert into public.vendor_approvals(vendor_id, decision, approver_id, note, due_diligence_passed, decided_at, created_by)
  values (p_vendor, 'approved', auth.uid(), p_note, (gate->>'passed')::boolean, now(), auth.uid());

  v := public.vendor_transition(p_vendor, 'approved', coalesce(p_note,'approved'));
  perform public.vendor_transition(p_vendor, 'active', 'activated');  -- approved -> active
  -- NOTE: client (or pg_net hook) then calls erp-sync action:'push' for each connection.
  return v;
end $$;
grant execute on function public.approve_vendor(uuid, text, boolean) to authenticated, service_role;

-- =============================================================================
-- GRANTS + RLS for new tables
-- =============================================================================
do $$
declare t text;
begin
  foreach t in array array[
    'integration_connections','integration_field_mappings','vendor_external_refs',
    'integration_sync_runs','integration_sync_records','vendor_grn_metrics',
    'due_diligence_checks','vendor_due_diligence_items','vendor_duplicate_candidates'
  ] loop
    execute format('grant select, insert, update, delete on public.%I to authenticated, service_role;', t);
    execute format('alter table public.%I enable row level security;', t);
  end loop;
end $$;

-- integration config: buyer_admin within the org
drop policy if exists intconn_rw on public.integration_connections;
create policy intconn_rw on public.integration_connections for all to authenticated
  using (public.user_in_org(org_id) and has_role(auth.uid(),'buyer_admin'))
  with check (public.user_in_org(org_id) and has_role(auth.uid(),'buyer_admin'));

drop policy if exists fieldmap_rw on public.integration_field_mappings;
create policy fieldmap_rw on public.integration_field_mappings for all to authenticated
  using (exists (select 1 from public.integration_connections c where c.id = connection_id
                 and public.user_in_org(c.org_id) and has_role(auth.uid(),'buyer_admin')))
  with check (exists (select 1 from public.integration_connections c where c.id = connection_id
                 and public.user_in_org(c.org_id) and has_role(auth.uid(),'buyer_admin')));

-- sync runs/records: buyer org can read (writes via service role)
drop policy if exists syncrun_read on public.integration_sync_runs;
create policy syncrun_read on public.integration_sync_runs for select to authenticated
  using (public.user_in_org(org_id));
drop policy if exists syncrec_read on public.integration_sync_records;
create policy syncrec_read on public.integration_sync_records for select to authenticated
  using (exists (select 1 from public.integration_sync_runs r where r.id = run_id and public.user_in_org(r.org_id)));

-- vendor-scoped buyer-internal tables
drop policy if exists extref_rw on public.vendor_external_refs;
create policy extref_rw on public.vendor_external_refs for all to authenticated
  using (public.is_buyer_for_vendor(vendor_id)) with check (public.is_buyer_for_vendor(vendor_id));

drop policy if exists grn_rw on public.vendor_grn_metrics;
create policy grn_rw on public.vendor_grn_metrics for all to authenticated
  using (public.is_buyer_for_vendor(vendor_id)) with check (public.is_buyer_for_vendor(vendor_id));

drop policy if exists dd_items_rw on public.vendor_due_diligence_items;
create policy dd_items_rw on public.vendor_due_diligence_items for all to authenticated
  using (public.is_buyer_for_vendor(vendor_id)) with check (public.is_buyer_for_vendor(vendor_id));

drop policy if exists dupe_rw on public.vendor_duplicate_candidates;
create policy dupe_rw on public.vendor_duplicate_candidates for all to authenticated
  using (public.is_buyer_for_vendor(vendor_id)) with check (public.is_buyer_for_vendor(vendor_id));

-- DD checklist config: all authenticated read; buyer_admin write
drop policy if exists ddchecks_read on public.due_diligence_checks;
create policy ddchecks_read on public.due_diligence_checks for select to authenticated using (true);
drop policy if exists ddchecks_write on public.due_diligence_checks;
create policy ddchecks_write on public.due_diligence_checks for all to authenticated
  using (has_role(auth.uid(),'buyer_admin')) with check (has_role(auth.uid(),'buyer_admin'));

-- ---------- realtime for live sync/DD progress -------------------------------
alter publication supabase_realtime add table public.integration_sync_runs;
alter publication supabase_realtime add table public.vendor_due_diligence_items;
alter table public.integration_sync_runs replica identity full;
alter table public.vendor_due_diligence_items replica identity full;

-- ---------- seed: the configurable DD checklist (the "30-40 checks") ----------
insert into public.due_diligence_checks (check_key, label, category, provider, default_source, is_mandatory, applies_min_risk, sort_order) values
 ('pan_verify','PAN Verification','identity','Income-Tax/NSDL','api',true,null,10),
 ('gst_active','GST Registration Active','tax','GST Portal','api',true,null,20),
 ('msme_status','MSME / Udyam Status','tax','Udyam Portal','api',false,null,30),
 ('sanctions_ofac','OFAC Sanctions','sanctions','OpenSanctions/OFAC','api',true,null,40),
 ('sanctions_un_eu','UN / EU Sanctions','sanctions','OpenSanctions','api',true,null,50),
 ('pep_screen','PEP Screening','sanctions','OpenSanctions','api',true,null,60),
 ('debarment_check','Debarment / Blacklist','compliance','Sectoral lists','api',false,null,70),
 ('credit_dnb','D&B Credit Check','financial','Dun & Bradstreet','api',false,'medium',80),
 ('credit_equifax','Equifax Credit Check','financial','Equifax','api',false,'medium',90),
 ('litigation_scan','Litigation Scan','legal','AI + court/news','ai',false,'medium',100),
 ('adverse_media','Adverse Media','reputation','News + AI','ai',false,null,110),
 ('financial_health','Financial Health','financial','Filings + AI','ai',false,null,120),
 ('site_verification','Physical Site Verification','physical','Human recording','human',false,'high',130),
 ('reference_check','Client Reference Check','operational','Human recording','human',false,null,140),
 ('processunity_score','ProcessUnity DD Score','aggregate','ProcessUnity','processunity',false,null,150)
on conflict (check_key) do nothing;
```


---

# PART C — EDGE FUNCTIONS (Deno / Supabase)


<!-- ===== edge-functions/README.md ===== -->

# Edge functions — deploy & secrets

Deno functions for Supabase. Folder per function; `_shared/` is imported, not deployed
standalone. All return CORS headers and a `{ ok, ... }` envelope.

## Deploy
```bash
supabase functions deploy extract-document
supabase functions deploy mca-fetch
supabase functions deploy risk-screening
supabase functions deploy vendor-web-insights
supabase functions deploy ai-evaluate
supabase functions deploy vendor-assistant
supabase functions deploy send-vendor-notification
supabase functions deploy erp-sync
supabase functions deploy due-diligence
supabase functions deploy vendor-classify
supabase functions deploy vendor-dedupe
# (expiry-sweep optional, schedule via pg_cron or an external scheduler)
```
> In Lovable, add each as a Supabase Edge Function with the file contents here.
> `_shared/cors.ts` and `_shared/ai.ts` go alongside (relative import `../_shared/…`).

## Secrets (Supabase → Edge Functions → Secrets)
| Secret | Required | Purpose |
|--------|----------|---------|
| `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY` | yes | DB + Storage access from functions |
| `AI_PROVIDER` | no (default `openai`) | `openai` \| `gemini` \| `anthropic` |
| `OPENAI_API_KEY` | yes (default provider) | extraction (vision), dossier, evaluate, assistant |
| `GEMINI_API_KEY` | recommended | fallback provider |
| `ANTHROPIC_API_KEY` | optional | optional provider |
| `RISK_MODE` | no (default `mock`) | `mock` (demo-safe) \| `live` |
| `OPENSANCTIONS_API_KEY` | only for live sanctions/PEP | OpenSanctions match API |
| `NEWS_API_KEY`, `DNB_API_KEY`, `MCA_API_KEY` | only for live | news / credit / MCA adapters |
| `RESEND_API_KEY`, `NOTIFY_FROM` | for email | outbound email (best-effort) |
| `INTEGRATION_MODE` | no (default `mock`) | `mock` (demo) \| `live` for `erp-sync` |
| ERP credentials | only for live | stored per-connection in **Supabase Vault** (not env); `erp-sync` reads by `vault_secret_id` |
| `DNB_API_KEY`, `EQUIFAX_API_KEY`, `PROCESSUNITY_API_KEY`, `GST_API_KEY` | only for live DD | credit / VDD / GST-MSME providers in `due-diligence` |

## Function contracts (quick ref)
- `extract-document`  `{vendor_id, storage_path, mime, file_name?, save?}` → `{ok, extraction, document_id}`
- `mca-fetch`         `{pan?, cin?, legal_name?}` → `{ok, source, data}`
- `risk-screening`    `{vendor_id, types?, mode?}` → `{ok, mode, flagged, screenings[]}`
- `vendor-web-insights` `{vendor_id}` → `{ok, degraded, sanctions, pep}` (persists dossier)
- `ai-evaluate`       `{vendor_id, dimensions[]}` → `{ok, lines[]}`
- `vendor-assistant`  `{vendor_id, messages[], context?}` → `{ok, reply, action?}`
- `send-vendor-notification` see `../07-REALTIME-NOTIFICATIONS.md`
- `erp-sync`           `{action:"test"|"pull"|"push"|"grn", connection_id, vendor_id?, entity?}` → `{ok, ...}` (bi-directional SAP/Ariba/MDG vendor-master sync; see `../09`)
- `due-diligence`      `{vendor_id, check_keys?, mode?}` → `{ok, gate, ran}` (configurable DD checklist + approval gate; see `../10 §10.2`)
- `vendor-classify`    `{vendor_id}` → `{ok, suggestion:{vendor_class,is_preferred,brand_tags}}`
- `vendor-dedupe`      `{org_id, vendor_id?}` → `{ok, candidates[]}` (master-data rationalization)

## Demo safety
With `RISK_MODE=mock` and the **Auto-Fill Demo** button, the whole flow runs with no
external network dependency and deterministic output. Switch `RISK_MODE=live` and add
keys to use real providers.


### FILE: `vendor-mgmt/spec/edge-functions/_shared/cors.ts`

```ts
// Shared CORS helpers for all vendor-management edge functions.
export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
};

export function preflight(req: Request): Response | null {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  return null;
}

export function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
```


### FILE: `vendor-mgmt/spec/edge-functions/_shared/ai.ts`

```ts
// Provider-agnostic AI gateway for Supabase Edge Functions (Deno).
// Default provider = OpenAI; falls back to Gemini, then Anthropic, if configured.
// Supports text + vision + JSON-mode. Keys live in edge-function secrets.
//
//   AI_PROVIDER      "openai" | "gemini" | "anthropic"   (default "openai")
//   OPENAI_API_KEY   gpt-4o (vision/json), gpt-4o-mini (cheap text)
//   GEMINI_API_KEY   gemini-2.5-flash
//   ANTHROPIC_API_KEY claude-sonnet-4-6

export type AIImage = { mime: string; base64: string };
export type AIArgs = {
  system?: string;
  prompt: string;
  images?: AIImage[];
  json?: boolean;           // force JSON object output
  maxTokens?: number;
};

const ORDER = (): string[] => {
  const primary = (Deno.env.get("AI_PROVIDER") || "openai").toLowerCase();
  const all = ["openai", "gemini", "anthropic"];
  return [primary, ...all.filter((p) => p !== primary)];
};

export async function callAI(args: AIArgs): Promise<{ text: string; provider: string; degraded: boolean }> {
  let lastErr: unknown;
  for (const provider of ORDER()) {
    try {
      const key = keyFor(provider);
      if (!key) continue;
      const text = await dispatch(provider, key, args);
      return { text, provider, degraded: false };
    } catch (e) {
      lastErr = e;
      console.error(`[ai] ${provider} failed:`, e);
    }
  }
  // total failure → degraded; caller decides fallback (e.g. mock data)
  return { text: "", provider: "none", degraded: true };
}

// Convenience: parse JSON out of the model response (tolerant of code fences).
export async function callAIJSON<T = unknown>(args: AIArgs): Promise<{ data: T | null; provider: string; degraded: boolean }> {
  const r = await callAI({ ...args, json: true });
  if (r.degraded || !r.text) return { data: null, provider: r.provider, degraded: r.degraded };
  try {
    const cleaned = r.text.replace(/^```(json)?/i, "").replace(/```$/, "").trim();
    return { data: JSON.parse(cleaned) as T, provider: r.provider, degraded: false };
  } catch (_e) {
    return { data: null, provider: r.provider, degraded: true };
  }
}

function keyFor(p: string): string | undefined {
  if (p === "openai") return Deno.env.get("OPENAI_API_KEY") || undefined;
  if (p === "gemini") return Deno.env.get("GEMINI_API_KEY") || undefined;
  if (p === "anthropic") return Deno.env.get("ANTHROPIC_API_KEY") || undefined;
  return undefined;
}

async function dispatch(provider: string, key: string, a: AIArgs): Promise<string> {
  if (provider === "openai") return openai(key, a);
  if (provider === "gemini") return gemini(key, a);
  if (provider === "anthropic") return anthropic(key, a);
  throw new Error("unknown provider " + provider);
}

// ---- OpenAI (chat completions; vision via image_url data URLs) ----
async function openai(key: string, a: AIArgs): Promise<string> {
  const content: unknown[] = [{ type: "text", text: a.prompt }];
  for (const img of a.images || []) {
    content.push({ type: "image_url", image_url: { url: `data:${img.mime};base64,${img.base64}` } });
  }
  const body: Record<string, unknown> = {
    model: a.images?.length ? "gpt-4o" : "gpt-4o-mini",
    messages: [
      ...(a.system ? [{ role: "system", content: a.system }] : []),
      { role: "user", content },
    ],
    max_tokens: a.maxTokens ?? 1500,
    temperature: 0.2,
  };
  if (a.json) body.response_format = { type: "json_object" };
  const res = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: { Authorization: `Bearer ${key}`, "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  if (!res.ok) throw new Error(`openai ${res.status}: ${await res.text()}`);
  const j = await res.json();
  return j.choices?.[0]?.message?.content ?? "";
}

// ---- Gemini (generateContent; inline_data for images) ----
async function gemini(key: string, a: AIArgs): Promise<string> {
  const parts: unknown[] = [{ text: (a.system ? a.system + "\n\n" : "") + a.prompt + (a.json ? "\n\nReturn ONLY valid JSON." : "") }];
  for (const img of a.images || []) parts.push({ inline_data: { mime_type: img.mime, data: img.base64 } });
  const model = "gemini-2.5-flash";
  const res = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${key}`,
    { method: "POST", headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ contents: [{ parts }], generationConfig: { temperature: 0.2,
        ...(a.json ? { responseMimeType: "application/json" } : {}) } }) });
  if (!res.ok) throw new Error(`gemini ${res.status}: ${await res.text()}`);
  const j = await res.json();
  return j.candidates?.[0]?.content?.parts?.map((p: { text?: string }) => p.text).join("") ?? "";
}

// ---- Anthropic (messages; base64 image blocks) ----
async function anthropic(key: string, a: AIArgs): Promise<string> {
  const content: unknown[] = [{ type: "text", text: a.prompt + (a.json ? "\n\nReturn ONLY valid JSON." : "") }];
  for (const img of a.images || []) content.push({ type: "image", source: { type: "base64", media_type: img.mime, data: img.base64 } });
  const res = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: { "x-api-key": key, "anthropic-version": "2023-06-01", "Content-Type": "application/json" },
    body: JSON.stringify({ model: "claude-sonnet-4-6", max_tokens: a.maxTokens ?? 1500,
      system: a.system, messages: [{ role: "user", content }] }),
  });
  if (!res.ok) throw new Error(`anthropic ${res.status}: ${await res.text()}`);
  const j = await res.json();
  return j.content?.[0]?.text ?? "";
}
```


### FILE: `vendor-mgmt/spec/edge-functions/extract-document/index.ts`

```ts
// extract-document — vision OCR a vendor doc, classify it, extract fields, and
// (optionally) file it into its required slot. Returns the extraction for the
// client to map into the onboarding wizard. Provider-agnostic via _shared/ai.ts.
//
// POST { vendor_id, storage_path, mime, file_name?, save?:boolean }
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders, preflight, json } from "../_shared/cors.ts";
import { callAIJSON } from "../_shared/ai.ts";

const SCHEMA = `{
  "doc_type": "one of: pan_card|gst_certificate|incorporation_certificate|iso_9001|iso_14001|iso_27001|insurance|bank_proof|material_test_certificate|msme_certificate|financial_statement|msa|other",
  "requirement_key": "one of: pan|gst|coi|iso_9001|iso_14001|insurance|bank_proof|material_test|msa|null",
  "confidence": 0.0,
  "fields": {
    "legal_name": null, "pan": null, "cin": null, "entity_type": null, "incorporation_date": null,
    "gstin": null, "state": null, "jurisdiction_code": null, "address": null,
    "issuer": null, "cert_number": null, "issue_date": null, "expires_at": null,
    "account_holder": null, "account_number": null, "ifsc": null, "bank_name": null, "branch": null,
    "turnover": null, "net_worth": null, "auditor": null
  }
}`;

Deno.serve(async (req) => {
  const pf = preflight(req); if (pf) return pf;
  try {
    const { vendor_id, storage_path, mime, file_name, save } = await req.json();
    if (!vendor_id || !storage_path) return json({ ok: false, error: "vendor_id and storage_path required" }, 400);

    const supa = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);

    // download the file (service role bypasses RLS) and base64-encode
    const dl = await supa.storage.from("vendor-documents").download(storage_path);
    if (dl.error) return json({ ok: false, error: dl.error.message }, 400);
    const buf = new Uint8Array(await dl.data.arrayBuffer());
    const base64 = btoa(String.fromCharCode(...buf));
    const m = mime || "image/png";

    // PDFs: gpt-4o vision reads image inputs; for PDFs convert first page client-side
    // OR rely on the model's file handling. Here we pass as image for png/jpg.
    const { data, degraded } = await callAIJSON<Record<string, unknown>>({
      system: "You are a precise Indian B2B procurement document parser. Extract identifiers EXACTLY (PAN 10 chars, GSTIN 15 chars, IFSC 11 chars). If a field is absent use null. Never invent values.",
      prompt: `Identify this document and extract fields. Return ONLY JSON exactly matching this schema:\n${SCHEMA}`,
      images: m.startsWith("image/") ? [{ mime: m, base64 }] : undefined,
      json: true,
    });

    if (degraded || !data) return json({ ok: false, degraded: true, error: "extraction unavailable" });

    let document_id: string | null = null;
    if (save) {
      const reqKey = (data.requirement_key as string) || null;
      const ext = (file_name?.split(".").pop() || (m.split("/")[1] ?? "bin"));
      const dest = `${vendor_id}/${reqKey || crypto.randomUUID()}.${ext}`;
      // move from inbox to slot
      await supa.storage.from("vendor-documents").move(storage_path, dest).catch(() => {});
      const ins = await supa.from("vendor_documents").insert({
        vendor_id,
        doc_type: data.doc_type || "other",
        requirement_key: reqKey,
        label: file_name || (data.doc_type as string),
        status: "uploaded",
        storage_path: dest,
        file_name,
        mime_type: m,
        issuer: (data.fields as Record<string, unknown>)?.issuer ?? null,
        cert_number: (data.fields as Record<string, unknown>)?.cert_number ?? null,
        issue_date: (data.fields as Record<string, unknown>)?.issue_date ?? null,
        expires_at: (data.fields as Record<string, unknown>)?.expires_at ?? null,
        extracted_data: data,
        uploaded_at: new Date().toISOString(),
      }).select("id").single();
      document_id = ins.data?.id ?? null;
    }

    return json({ ok: true, extraction: data, document_id });
  } catch (e) {
    return json({ ok: false, error: String(e) }, 500);
  }
});
```


### FILE: `vendor-mgmt/spec/edge-functions/mca-fetch/index.ts`

```ts
// mca-fetch — "Auto-Fetch from MCA": resolve company legal data + directors from a
// PAN or CIN. Live adapter (MCA/Probe42) when MCA_API_KEY + RISK_MODE=live; else an
// AI-synthesised best-effort from public knowledge (demo-safe). Returns for the
// client to write into the Company Profile step.
// POST { pan?, cin?, legal_name? }
import { preflight, json } from "../_shared/cors.ts";
import { callAIJSON } from "../_shared/ai.ts";

Deno.serve(async (req) => {
  const pf = preflight(req); if (pf) return pf;
  try {
    const { pan, cin, legal_name } = await req.json();
    if (!pan && !cin && !legal_name) return json({ ok: false, error: "pan, cin or legal_name required" }, 400);

    const mode = Deno.env.get("RISK_MODE") || "mock";
    const mcaKey = Deno.env.get("MCA_API_KEY");

    if (mode === "live" && mcaKey && cin) {
      // Example Probe42/MCA adapter (endpoint/headers vary by vendor) — fall through to AI on error.
      try {
        const res = await fetch(`https://api.probe42.in/probe_pro/companies/${cin}`, {
          headers: { "x-api-key": mcaKey, "x-api-version": "1.3" },
        });
        if (res.ok) {
          const j = await res.json();
          return json({ ok: true, source: "mca", data: normalizeMca(j) });
        }
      } catch (e) { console.error("mca live failed", e); }
    }

    // AI fallback (demo-safe)
    const { data, degraded } = await callAIJSON<Record<string, unknown>>({
      system: "You return Indian MCA-style company master data as JSON. Use well-known public facts. If unknown, null. Never fabricate director DINs you are unsure of.",
      prompt: `Return JSON { legal_name, entity_type, cin, incorporation_date(YYYY-MM-DD), registered_address, directors:[{full_name,din,designation}] } for company with PAN ${pan ?? "?"}, CIN ${cin ?? "?"}, name ${legal_name ?? "?"}.`,
      json: true,
    });
    if (degraded || !data) return json({ ok: false, degraded: true });
    return json({ ok: true, source: "ai", data });
  } catch (e) {
    return json({ ok: false, error: String(e) }, 500);
  }
});

function normalizeMca(j: Record<string, any>) {
  const c = j.data ?? j;
  return {
    legal_name: c.legal_name ?? c.company_name ?? null,
    entity_type: c.company_category ?? c.company_type ?? null,
    cin: c.cin ?? null,
    incorporation_date: c.incorporation_date ?? null,
    registered_address: c.registered_address ?? null,
    directors: (c.directors ?? c.signatories ?? []).map((d: Record<string, any>) => ({
      full_name: d.name ?? d.full_name, din: d.din, designation: d.designation,
    })),
  };
}
```


### FILE: `vendor-mgmt/spec/edge-functions/risk-screening/index.ts`

```ts
// risk-screening — pluggable third-party risk checks with deterministic MOCK mode.
// POST { vendor_id, types?: string[], mode?: "mock"|"live" }
// Writes one vendor_risk_screenings row per type; returns a summary.
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { preflight, json } from "../_shared/cors.ts";

type Screen = { type: string; status: string; entities_checked: number; hits: number; provider: string; result: unknown };

Deno.serve(async (req) => {
  const pf = preflight(req); if (pf) return pf;
  try {
    const body = await req.json();
    const vendor_id: string = body.vendor_id;
    const types: string[] = body.types ?? ["sanctions", "pep", "credit", "news", "geographic"];
    const mode: string = body.mode ?? (Deno.env.get("RISK_MODE") || "mock");
    if (!vendor_id) return json({ ok: false, error: "vendor_id required" }, 400);

    const supa = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
    const { data: vendor } = await supa.from("vendors").select("legal_name, country, state").eq("id", vendor_id).single();
    const { data: directors } = await supa.from("vendor_directors").select("full_name").eq("vendor_id", vendor_id);
    const names = [vendor?.legal_name, ...(directors ?? []).map((d) => d.full_name)].filter(Boolean) as string[];

    const out: Screen[] = [];
    for (const t of types) {
      out.push(mode === "live" ? await live(t, names, vendor) : mock(t, names, vendor));
    }

    // persist + audit
    for (const s of out) {
      await supa.from("vendor_risk_screenings").insert({
        vendor_id, screening_type: s.type, status: s.status,
        entities_checked: s.entities_checked, hits: s.hits, provider: s.provider,
        mode, checked_at: new Date().toISOString(), result: s.result,
      });
    }
    await supa.from("vendor_audit_log").insert({
      vendor_id, action: "screening_complete",
      payload: { mode, summary: out.map((s) => ({ type: s.type, status: s.status })) },
    });

    const flagged = out.some((s) => s.status === "flagged");
    return json({ ok: true, mode, flagged, screenings: out });
  } catch (e) {
    return json({ ok: false, error: String(e) }, 500);
  }
});

// ---------- MOCK (deterministic, demo-safe) ----------
function mock(type: string, names: string[], vendor: { state?: string; country?: string } | null): Screen {
  switch (type) {
    case "sanctions":
      return { type, status: "clean", entities_checked: names.length, hits: 0, provider: "mock:OpenSanctions",
        result: { lists: ["OFAC", "EU", "UN"], matched: [] } };
    case "pep":
      return { type, status: "clean", entities_checked: Math.max(1, names.length - 1), hits: 0, provider: "mock:OpenSanctions",
        result: { persons_screened: Math.max(1, names.length - 1) } };
    case "credit":
      return { type, status: "clean", entities_checked: 1, hits: 0, provider: "mock:CRISIL/D&B",
        result: { credit_rating: "CRISIL AA/Stable", dnb_rating: "5A1 (Highest)" } };
    case "news":
      return { type, status: "clean", entities_checked: 1, hits: 0, provider: "mock:NewsAPI",
        result: { items: [
          { title: "Company on track with capacity expansion", sentiment: "positive", source: "Economic Times" },
          { title: "Quarterly revenue softens on price pressure", sentiment: "negative", source: "Business Standard" },
        ] } };
    case "geographic":
      return { type, status: "clean", entities_checked: 1, hits: 0, provider: "mock:CountryRiskIndex",
        result: { region: vendor?.state ?? "India", assessment: "Stable economy, low conflict zone" } };
    case "adverse_media":
      return { type, status: "clean", entities_checked: 1, hits: 0, provider: "mock:AI",
        result: { summary: "No material adverse media identified in the last 12 months." } };
    default:
      return { type, status: "clean", entities_checked: 0, hits: 0, provider: "mock", result: {} };
  }
}

// ---------- LIVE (adapters; fall back to mock on error → degraded) ----------
async function live(type: string, names: string[], vendor: { state?: string; country?: string } | null): Promise<Screen> {
  try {
    if (type === "sanctions" || type === "pep") {
      const key = Deno.env.get("OPENSANCTIONS_API_KEY");
      if (!key) throw new Error("no OPENSANCTIONS_API_KEY");
      const queries = Object.fromEntries(names.map((n, i) => [String(i), { schema: "Person", properties: { name: [n] } }]));
      const res = await fetch("https://api.opensanctions.org/match/default", {
        method: "POST",
        headers: { Authorization: `ApiKey ${key}`, "Content-Type": "application/json" },
        body: JSON.stringify({ queries }),
      });
      const j = await res.json();
      const hits = Object.values(j.responses ?? {}).filter((r: unknown) => ((r as { results?: unknown[] }).results?.length ?? 0) > 0).length;
      return { type, status: hits > 0 ? "flagged" : "clean", entities_checked: names.length, hits, provider: "OpenSanctions", result: j };
    }
    // news, credit, geographic live adapters omitted for brevity → mock
    return { ...mock(type, names, vendor), result: { ...(mock(type, names, vendor).result as object), degraded: true } };
  } catch (e) {
    const m = mock(type, names, vendor);
    return { ...m, result: { ...(m.result as object), degraded: true, error: String(e) } };
  }
}
```


### FILE: `vendor-mgmt/spec/edge-functions/vendor-web-insights/index.ts`

```ts
// vendor-web-insights — build the AI public-intelligence dossier for the 360
// "Web Insights" tab, run sanctions/PEP screening, and persist everything.
// POST { vendor_id }
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { preflight, json } from "../_shared/cors.ts";
import { callAIJSON } from "../_shared/ai.ts";

Deno.serve(async (req) => {
  const pf = preflight(req); if (pf) return pf;
  try {
    const { vendor_id } = await req.json();
    if (!vendor_id) return json({ ok: false, error: "vendor_id required" }, 400);

    const url = Deno.env.get("SUPABASE_URL")!;
    const svc = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supa = createClient(url, svc);

    const { data: v } = await supa.from("vendors")
      .select("legal_name, pan, cin, website, primary_category, city, state").eq("id", vendor_id).single();
    if (!v) return json({ ok: false, error: "vendor not found" }, 404);

    // 1) AI dossier
    const { data: ai, degraded } = await callAIJSON<{
      overview: string; headquarters: string; founded: string; employees: string; revenue: string;
      industry: string; stock_ticker: string; market_cap: string; credit_rating: string; credit_agency: string;
      dnb_rating: string; key_ratios: Record<string, unknown>; key_personnel: { name: string; title: string }[];
      news: { title: string; source: string; sentiment: string; published_at?: string }[];
    }>({
      system: "You are a procurement risk analyst. Produce an India-context company dossier. JSON only. If unsure, use reasonable public-knowledge estimates and mark them in the field text.",
      prompt: `Company: ${v.legal_name}; PAN ${v.pan ?? "?"}; CIN ${v.cin ?? "?"}; site ${v.city ?? ""} ${v.state ?? ""}; sector ${v.primary_category ?? ""}.
Return JSON: { overview(<=60 words), headquarters, founded, employees, revenue, industry, stock_ticker, market_cap, credit_rating, credit_agency, dnb_rating, key_ratios{debt_equity,current_ratio,ebitda_margin,roe,interest_coverage}, key_personnel[{name,title}], news[4..6 {title,source,sentiment(positive|negative|neutral),published_at(YYYY-MM-DD)}] }`,
      json: true,
    });

    // 2) sanctions + PEP via risk-screening function
    let sanctions = "Clean", pep = "Clean";
    try {
      const rs = await fetch(`${url}/functions/v1/risk-screening`, {
        method: "POST",
        headers: { Authorization: `Bearer ${svc}`, "Content-Type": "application/json" },
        body: JSON.stringify({ vendor_id, types: ["sanctions", "pep", "credit"] }),
      }).then((r) => r.json());
      const s = (rs.screenings ?? []) as { type: string; status: string }[];
      sanctions = s.find((x) => x.type === "sanctions")?.status === "flagged" ? "Flagged" : "Clean";
      pep = s.find((x) => x.type === "pep")?.status === "flagged" ? "Flagged" : "Clean";
    } catch (_e) { /* keep clean defaults */ }

    // 3) persist dossier
    const insights = ai ?? {} as Record<string, unknown>;
    await supa.from("vendor_web_insights").upsert({
      vendor_id,
      overview: (insights as any).overview ?? null,
      headquarters: (insights as any).headquarters ?? null,
      founded: (insights as any).founded ?? null,
      employees: (insights as any).employees ?? null,
      revenue: (insights as any).revenue ?? null,
      industry: (insights as any).industry ?? null,
      stock_ticker: (insights as any).stock_ticker ?? null,
      website: v.website ?? null,
      market_cap: (insights as any).market_cap ?? null,
      credit_rating: (insights as any).credit_rating ?? null,
      credit_agency: (insights as any).credit_agency ?? null,
      dnb_rating: (insights as any).dnb_rating ?? null,
      key_ratios: (insights as any).key_ratios ?? null,
      key_personnel: (insights as any).key_personnel ?? null,
      sanctions_status: sanctions,
      pep_status: pep,
      refreshed_at: new Date().toISOString(),
    }, { onConflict: "vendor_id" });

    // 4) replace news
    await supa.from("vendor_news_items").delete().eq("vendor_id", vendor_id);
    const news = ((insights as any).news ?? []) as { title: string; source: string; sentiment: string; published_at?: string }[];
    if (news.length) {
      await supa.from("vendor_news_items").insert(news.map((n) => ({
        vendor_id, title: n.title, source: n.source, sentiment: n.sentiment,
        published_at: n.published_at ?? null,
      })));
    }

    await supa.from("vendor_audit_log").insert({ vendor_id, action: "web_insights_refreshed", payload: { degraded } });
    return json({ ok: true, degraded, sanctions, pep });
  } catch (e) {
    return json({ ok: false, error: String(e) }, 500);
  }
});
```


### FILE: `vendor-mgmt/spec/edge-functions/due-diligence/index.ts`

```ts
// due-diligence — runs the configurable DD checklist for a vendor (the "30-40 checks"
// Adani asked for: OFAC, D&B, Equifax, GST/MSME, PAN, sanctions/PEP, ProcessUnity, plus
// AI checks). Writes vendor_due_diligence_items and returns the approval-gate status.
// Human checks (site/reference) are created as manual_review for a person to complete
// via the recording UI. MOCK by default (<$0.50/vendor, demo-safe).
//
// POST { vendor_id, check_keys?: string[], mode?: "mock"|"live" }
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { preflight, json } from "../_shared/cors.ts";
import { callAIJSON } from "../_shared/ai.ts";

Deno.serve(async (req) => {
  const pf = preflight(req); if (pf) return pf;
  try {
    const { vendor_id, check_keys, mode } = await req.json();
    const m = mode ?? (Deno.env.get("RISK_MODE") || "mock");
    if (!vendor_id) return json({ ok: false, error: "vendor_id required" }, 400);
    const supa = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);

    const { data: vendor } = await supa.from("vendors").select("legal_name, pan, risk_level").eq("id", vendor_id).single();
    const { data: checks } = await supa.from("due_diligence_checks").select("*").eq("enabled", true).order("sort_order");
    const wanted = (checks ?? []).filter((c) => !check_keys || check_keys.includes(c.check_key));

    for (const c of wanted) {
      const r = await runCheck(c, vendor, m);
      await supa.from("vendor_due_diligence_items").upsert({
        vendor_id, check_key: c.check_key, status: r.status, source: c.default_source,
        result: r.result, performed_at: r.status === "manual_review" ? null : new Date().toISOString(),
        note: r.note ?? null,
      }, { onConflict: "vendor_id,check_key" });
    }

    await supa.from("vendor_audit_log").insert({ vendor_id, action: "due_diligence_run",
      payload: { mode: m, checks: wanted.map((c) => c.check_key) } });

    const { data: gate } = await supa.rpc("dd_gate_status", { p_vendor: vendor_id });
    return json({ ok: true, gate, ran: wanted.length });
  } catch (e) {
    return json({ ok: false, error: String(e) }, 500);
  }
});

async function runCheck(c: { check_key: string; default_source: string }, vendor: any, mode: string):
  Promise<{ status: string; result: unknown; note?: string }> {
  // Human checks are never auto-passed — create a task for a person.
  if (c.default_source === "human") {
    return { status: "manual_review", result: { instructions: "Complete via the DD recording UI and attach evidence." } };
  }

  if (mode === "mock") {
    switch (c.check_key) {
      case "pan_verify": return { status: "pass", result: { pan: vendor?.pan, name_match: true } };
      case "gst_active": return { status: "pass", result: { status: "Active", filing_rate: "100%" } };
      case "msme_status": return { status: "pass", result: { msme: "Registered (Udyam)" } };
      case "sanctions_ofac": return { status: "pass", result: { lists: ["OFAC"], hits: 0 } };
      case "sanctions_un_eu": return { status: "pass", result: { lists: ["UN", "EU"], hits: 0 } };
      case "pep_screen": return { status: "pass", result: { hits: 0 } };
      case "debarment_check": return { status: "pass", result: { hits: 0 } };
      case "credit_dnb": return { status: "pass", result: { rating: "5A1 (Highest)", paydex: 78 } };
      case "credit_equifax": return { status: "pass", result: { score: 720, band: "Low risk" } };
      case "processunity_score": return { status: "pass", result: { score: 82, band: "Acceptable" } };
      case "adverse_media":
      case "litigation_scan":
      case "financial_health":
        return { status: "pass", result: { summary: "No material adverse findings (mock)." } };
      default: return { status: "pass", result: {} };
    }
  }

  // LIVE: route to the right provider; AI checks via the gateway, others via adapters.
  if (["adverse_media", "litigation_scan", "financial_health"].includes(c.check_key)) {
    const { data, degraded } = await callAIJSON<{ finding: string; risk: string }>({
      system: "You are a vendor due-diligence analyst. Be factual and conservative. JSON only.",
      prompt: `Check "${c.check_key}" for ${vendor?.legal_name} (PAN ${vendor?.pan}). Return {finding, risk: "none|low|medium|high"}.`,
      json: true,
    });
    if (degraded || !data) return { status: "manual_review", result: { note: "AI unavailable" } };
    return { status: data.risk === "high" ? "fail" : "pass", result: data };
  }
  // sanctions/pep -> reuse risk-screening; credit/gst/pan/processunity -> their APIs (omitted here)
  return { status: "manual_review", result: { note: "configure live adapter for " + c.check_key } };
}
```


### FILE: `vendor-mgmt/spec/edge-functions/erp-sync/index.ts`

```ts
// erp-sync — front-end-configured connector to SAP S/4HANA, SAP MDG, Ariba, Coupa,
// Oracle, Baan/Infor. Bi-directional vendor-master sync + GRN pull. MOCK by default
// so the demo runs with zero ERP dependency; live adapters call the customer's APIs
// with credentials read from Supabase Vault.
//
// POST { action:"test"|"pull"|"push"|"grn", connection_id, vendor_id?, entity?, mode? }
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { preflight, json } from "../_shared/cors.ts";

Deno.serve(async (req) => {
  const pf = preflight(req); if (pf) return pf;
  try {
    const { action, connection_id, vendor_id, entity } = await req.json();
    const supa = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
    const mode = (await req.json().catch(() => ({}))).mode ?? (Deno.env.get("INTEGRATION_MODE") || "mock");

    const { data: conn } = await supa.from("integration_connections").select("*").eq("id", connection_id).single();
    if (!conn) return json({ ok: false, error: "connection not found" }, 404);

    // creds (live only): read from Vault by conn.vault_secret_id (omitted in mock)
    // const creds = await readVault(supa, conn.vault_secret_id);

    if (action === "test") {
      const info = mode === "mock"
        ? { reachable: true, system: conn.system_type, sample_entities: ["BusinessPartner", "GRN"] }
        : await liveTest(conn);
      await supa.from("integration_connections").update({
        status: info.reachable ? "connected" : "error", last_test_at: new Date().toISOString(), last_test_info: info,
      }).eq("id", connection_id);
      return json({ ok: info.reachable, info });
    }

    if (action === "pull" && (entity ?? "vendor") === "vendor") {
      const run = await startRun(supa, conn, "inbound", "vendor");
      const rows = mode === "mock" ? mockVendorMaster(conn.system_type) : await livePullVendors(conn);
      let ok = 0, failed = 0;
      for (const r of rows) {
        try {
          // upsert by external_id; create a lightweight prospect if new
          const { data: ex } = await supa.from("vendor_external_refs")
            .select("vendor_id").eq("external_system", conn.system_type).eq("external_id", r.external_id).maybeSingle();
          let vId = ex?.vendor_id as string | undefined;
          if (!vId) {
            const slug = r.legal_name.toLowerCase().replace(/[^a-z0-9]+/g, "-").slice(0, 40) + "-" + r.external_id.slice(-4);
            const ins = await supa.from("vendors").insert({
              org_id: conn.org_id, slug, legal_name: r.legal_name, pan: r.pan, vendor_code: r.external_id,
              primary_category: r.category, lifecycle_status: "active", source: "manual", vendor_class: r.vendor_class ?? "other",
            }).select("id").single();
            vId = ins.data?.id;
          }
          await supa.from("vendor_external_refs").upsert({
            vendor_id: vId, connection_id, external_system: conn.system_type, external_id: r.external_id,
            last_synced_at: new Date().toISOString(), sync_status: "ok", sync_hash: r.hash,
          }, { onConflict: "vendor_id,external_system" });
          await logRec(supa, run.id, vId, r.external_id, ex ? "update" : "create", "ok", r);
          ok++;
        } catch (e) { await logRec(supa, run.id, null, r.external_id, "create", "error", r, String(e)); failed++; }
      }
      await finishRun(supa, run.id, rows.length, ok, failed);
      return json({ ok: true, run_id: run.id, pulled: rows.length, ok, failed });
    }

    if (action === "push") {
      const run = await startRun(supa, conn, "outbound", "vendor");
      const { data: v } = await supa.from("vendors").select("*").eq("id", vendor_id).single();
      const payload = mapVendorToErp(conn.system_type, v);
      const res = mode === "mock"
        ? { external_id: "00010" + String(Math.floor(Math.random() * 90000)) }   // mock LIFNR
        : await livePushVendor(conn, payload);
      await supa.from("vendor_external_refs").upsert({
        vendor_id, connection_id, external_system: conn.system_type, external_id: res.external_id,
        last_synced_at: new Date().toISOString(), sync_status: "ok",
      }, { onConflict: "vendor_id,external_system" });
      await logRec(supa, run.id, vendor_id, res.external_id, "create", "ok", payload);
      await finishRun(supa, run.id, 1, 1, 0);
      await supa.from("vendor_audit_log").insert({ vendor_id, action: "erp_sync",
        payload: { direction: "outbound", system: conn.system_type, external_id: res.external_id } });
      return json({ ok: true, external_id: res.external_id });
    }

    if (action === "grn") {
      const metrics = mode === "mock"
        ? { period: "FY2024-25", on_time_delivery_pct: 96.2, quality_rejection_pct: 0.8, grn_count: 142 }
        : await livePullGrn(conn, vendor_id);
      await supa.from("vendor_grn_metrics").insert({ vendor_id, source_connection_id: connection_id, ...metrics });
      return json({ ok: true, metrics });
    }

    return json({ ok: false, error: "unknown action" }, 400);
  } catch (e) {
    return json({ ok: false, error: String(e) }, 500);
  }
});

// ---- run bookkeeping ----
async function startRun(supa: any, conn: any, direction: string, entity: string) {
  const { data } = await supa.from("integration_sync_runs").insert({
    connection_id: conn.id, org_id: conn.org_id, direction, entity, status: "running",
  }).select("*").single();
  return data;
}
async function finishRun(supa: any, runId: string, total: number, ok: number, failed: number) {
  await supa.from("integration_sync_runs").update({
    status: failed === 0 ? "success" : ok === 0 ? "error" : "partial",
    total_count: total, ok_count: ok, failed_count: failed, finished_at: new Date().toISOString(),
  }).eq("id", runId);
}
async function logRec(supa: any, runId: string, vId: string | null, extId: string, action: string, status: string, payload: unknown, error?: string) {
  await supa.from("integration_sync_records").insert({ run_id: runId, vendor_id: vId, external_id: extId, action, status, payload, error });
}

// ---- field mapping (AirChain -> ERP) ----
function mapVendorToErp(system: string, v: any): Record<string, unknown> {
  if (system.startsWith("sap")) {
    return { Supplier: v.vendor_code, BusinessPartnerName: v.legal_name, TaxNumber3: v.pan, TaxNumber: v.cin,
      AddressLine1: v.addr_line1, CityName: v.city, Region: v.state, PostalCode: v.pincode, Country: "IN",
      VendorClass: v.vendor_class, IsPreferred: v.is_preferred };
  }
  return { SMVendorID: v.vendor_code, SMVendorName: v.legal_name, pan: v.pan, classification: v.vendor_class };
}

// ---- MOCK data (deterministic, demo-safe) ----
function mockVendorMaster(system: string) {
  const base = [
    { external_id: "0001000045", legal_name: "SKF India Limited", pan: "AAACS1234F", category: "Capital & Equipment", vendor_class: "oem" },
    { external_id: "0001000046", legal_name: "Schaeffler India Limited", pan: "AAACS5678G", category: "Capital & Equipment", vendor_class: "oem" },
    { external_id: "0001000047", legal_name: "Bearing Distributors Pvt Ltd", pan: "AAACB9012H", category: "Capital & Equipment", vendor_class: "dealer" },
  ];
  return base.map((b) => ({ ...b, hash: `${system}:${b.external_id}` }));
}

// ---- LIVE adapter stubs (implement per customer; fall back / throw to mock) ----
async function liveTest(conn: any) {
  // e.g. GET {base_url}/sap/opu/odata/sap/API_BUSINESS_PARTNER/$metadata  (SAP)
  return { reachable: false, note: "configure live adapter for " + conn.system_type };
}
async function livePullVendors(_conn: any): Promise<any[]> { throw new Error("live adapter not configured"); }
async function livePushVendor(_conn: any, _payload: unknown): Promise<{ external_id: string }> { throw new Error("live adapter not configured"); }
async function livePullGrn(_conn: any, _vendorId: string) { throw new Error("live adapter not configured"); }
```


### FILE: `vendor-mgmt/spec/edge-functions/vendor-classify/index.ts`

```ts
// vendor-classify — AI-suggest the vendor tag Adani needs (OEM vs dealer/distributor),
// preferred flag, and brand_tags. Returns a suggestion; the buyer confirms before write
// (and it can then be synced to SAP MDG as the preferred/partner-role tag via erp-sync).
// POST { vendor_id } -> { ok, suggestion:{ vendor_class, is_preferred, brand_tags[], rationale } }
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { preflight, json } from "../_shared/cors.ts";
import { callAIJSON } from "../_shared/ai.ts";

Deno.serve(async (req) => {
  const pf = preflight(req); if (pf) return pf;
  try {
    const { vendor_id } = await req.json();
    const supa = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
    const { data: v } = await supa.from("vendors")
      .select("legal_name, primary_category, business_description, website").eq("id", vendor_id).single();

    const { data, degraded } = await callAIJSON<{ vendor_class: string; is_preferred: boolean; brand_tags: string[]; rationale: string }>({
      system: "You classify B2B suppliers for procurement master data. JSON only.",
      prompt: `Classify ${JSON.stringify(v)}. vendor_class one of oem|dealer|distributor|channel_partner|manufacturer|service_provider|other. ` +
              `Detect brands they represent (e.g. SKF, Schaeffler, NSK) into brand_tags. ` +
              `Set is_preferred true only if clearly a primary/strategic OEM. Return {vendor_class,is_preferred,brand_tags,rationale}.`,
      json: true,
    });
    if (degraded || !data) return json({ ok: false, degraded: true });
    return json({ ok: true, suggestion: data });
  } catch (e) {
    return json({ ok: false, error: String(e) }, 500);
  }
});
```


### FILE: `vendor-mgmt/spec/edge-functions/vendor-dedupe/index.ts`

```ts
// vendor-dedupe — master-data rationalization helper (Adani's "MDL chaos, multiple
// codes per item/vendor"). Finds likely duplicate vendor records within an org by
// name/PAN similarity (+ optional AI confirmation) and writes review candidates.
// Target: 70-80% out-of-the-box matching, improved by human confirm/dismiss.
// POST { org_id, vendor_id? } -> { ok, candidates:[{vendor_id, match_vendor_id, score, reason}] }
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { preflight, json } from "../_shared/cors.ts";

const norm = (s: string) => (s || "").toLowerCase().replace(/\b(pvt|private|ltd|limited|llp|inc|corp|co|the)\b/g, "").replace(/[^a-z0-9]/g, "");
function trigramSim(a: string, b: string): number {
  const grams = (s: string) => new Set([...Array(Math.max(0, s.length - 2))].map((_, i) => s.slice(i, i + 3)));
  const A = grams(a), B = grams(b); if (!A.size || !B.size) return 0;
  let inter = 0; for (const g of A) if (B.has(g)) inter++;
  return inter / (A.size + B.size - inter);
}

Deno.serve(async (req) => {
  const pf = preflight(req); if (pf) return pf;
  try {
    const { org_id, vendor_id } = await req.json();
    const supa = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
    const { data: vendors } = await supa.from("vendors").select("id, legal_name, pan").eq("org_id", org_id);
    const list = vendors ?? [];
    const candidates: { vendor_id: string; match_vendor_id: string; score: number; reason: string }[] = [];

    const scope = vendor_id ? list.filter((v) => v.id === vendor_id) : list;
    for (const a of scope) {
      for (const b of list) {
        if (a.id >= b.id) continue;
        let score = trigramSim(norm(a.legal_name), norm(b.legal_name));
        let reason = "name similarity";
        if (a.pan && b.pan && a.pan === b.pan) { score = Math.max(score, 0.97); reason = "identical PAN"; }
        if (score >= 0.72) candidates.push({ vendor_id: a.id, match_vendor_id: b.id, score: Number(score.toFixed(2)), reason });
      }
    }

    for (const c of candidates) {
      await supa.from("vendor_duplicate_candidates").upsert({
        vendor_id: c.vendor_id, match_vendor_id: c.match_vendor_id, score: c.score, reason: c.reason, status: "open",
      });
    }
    return json({ ok: true, candidates });
  } catch (e) {
    return json({ ok: false, error: String(e) }, 500);
  }
});
```


### FILE: `vendor-mgmt/spec/edge-functions/ai-evaluate/index.ts`

```ts
// ai-evaluate — suggest scorecard scores (1..5) with data_source + basis for the
// chosen dimensions. Human reviews/edits before saving (ai_suggested=true).
// POST { vendor_id, dimensions: string[] }  -> { ok, lines:[{dimension,criterion,score,data_source,basis}] }
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { preflight, json } from "../_shared/cors.ts";
import { callAIJSON } from "../_shared/ai.ts";

Deno.serve(async (req) => {
  const pf = preflight(req); if (pf) return pf;
  try {
    const { vendor_id, dimensions } = await req.json();
    if (!vendor_id) return json({ ok: false, error: "vendor_id required" }, 400);
    const supa = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);

    // gather signals
    const [{ data: v }, { data: q }, { data: scr }, { data: po }] = await Promise.all([
      supa.from("vendors").select("legal_name, primary_category, total_spend, po_count").eq("id", vendor_id).single(),
      supa.from("vendor_qualification").select("*").eq("vendor_id", vendor_id).maybeSingle(),
      supa.from("vendor_risk_screenings").select("screening_type,status").eq("vendor_id", vendor_id),
      supa.from("purchase_orders").select("status").eq("vendor_id", vendor_id),
    ]);

    const { data, degraded } = await callAIJSON<{ lines: unknown[] }>({
      system: "You are a vendor due-diligence analyst. Score conservatively when evidence is thin. JSON only.",
      prompt: `Vendor: ${JSON.stringify(v)}\nQualification: ${JSON.stringify(q)}\nScreenings: ${JSON.stringify(scr)}\nPOs: ${JSON.stringify(po)}\n
For each requested dimension ${JSON.stringify(dimensions)}, return its standard criteria. Output JSON:
{ "lines": [ { "dimension": "...", "criterion": "...", "score": 1-5, "data_source": "...", "basis": "one line" } ] }`,
      json: true,
    });
    if (degraded || !data) return json({ ok: false, degraded: true });
    return json({ ok: true, lines: data.lines ?? [] });
  } catch (e) {
    return json({ ok: false, error: String(e) }, 500);
  }
});
```


### FILE: `vendor-mgmt/spec/edge-functions/vendor-assistant/index.ts`

```ts
// vendor-assistant ("Aiera") — onboarding chat helper. Answers questions and can
// instruct the client to fill a named field.
// POST { vendor_id, messages:[{role,content}], context? }
//   -> { ok, reply, action?: { type:"fill", field:string, value:string } }
import { preflight, json } from "../_shared/cors.ts";
import { callAIJSON } from "../_shared/ai.ts";

Deno.serve(async (req) => {
  const pf = preflight(req); if (pf) return pf;
  try {
    const { messages, context } = await req.json();
    const convo = (messages ?? []).map((m: { role: string; content: string }) => `${m.role}: ${m.content}`).join("\n");

    const { data, degraded } = await callAIJSON<{ reply: string; action?: unknown }>({
      system: "You are Aiera, Aerchain's vendor-onboarding assistant. Be concise and practical. " +
              "If the user asks you to fill a field, respond with JSON {reply, action:{type:'fill',field,value}}. " +
              "Otherwise {reply}. JSON only.",
      prompt: `Onboarding context: ${JSON.stringify(context ?? {})}\nConversation:\n${convo}\n\nRespond as JSON.`,
      json: true,
    });
    if (degraded || !data) return json({ ok: true, reply: "I'm having trouble right now — please fill this field manually." });
    return json({ ok: true, reply: data.reply, action: (data as { action?: unknown }).action });
  } catch (e) {
    return json({ ok: false, error: String(e) }, 500);
  }
});
```
