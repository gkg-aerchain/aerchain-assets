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
