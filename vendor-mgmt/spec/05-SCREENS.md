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
