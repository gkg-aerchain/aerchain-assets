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
