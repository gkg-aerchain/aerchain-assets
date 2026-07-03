# Aerchain × Adani — Vendor Management Module · Build Handoff

This file hands a fresh Claude Code session everything it needs to build the **Vendor Management module** inside the Aerchain S2P application, matching the live product theme and the requirements we scoped for Adani.

---

## ▶ PASTE THIS AS THE INITIALIZATION PROMPT

> You are building the **Vendor & Supplier Management module** for the Aerchain S2P ("source-to-pay") web application, scoped to the requirements Adani Group set out in their *Digital Transformation in Procurement Processes (Supplier & Sourcing Management)* RFP.
>
> **Repo:** build in **`gkg-aerchain/aerchain-s2p`** — the live S2P web application. Do **NOT** build in `aerchain-s2p-solution-map` (that is only the process/blueprint map, not the app). First, **study the existing codebase**: framework (Next.js/React?), the design-system / component library, routing, state management, data layer (API/mock), and how existing modules are structured. **Reuse existing components and patterns** — do not introduce a parallel design system.
>
> **Goal:** ship a comprehensive, genuinely usable Vendor Management module. Intuitive UI, **no over-complicated settings page**, no unintuitive flows. Prefer sensible defaults with light per-BU configuration over a wall of toggles. Where the backend isn't ready, use typed mock/seed data and a clean service layer so it swaps to real APIs later. Deliver as a PR (or a feature branch) with small, reviewable commits.
>
> **Source of truth:** the attached **PRD** (`Aerchain-Adani-Supplier-Sourcing-PRD.html`) — 86 numbered functional requirements across 11 modules, each with acceptance criteria, plus the business-rule catalogue, use cases (UC1–UC30), data/identity model and integration surfaces. Build to those FR IDs. The attached **Process Blueprint** shows the as-is/to-be flows; the **Integration Brief** defines the identity model; the **demo screenshots** define the exact visual theme.
>
> **Build order (thin vertical slices, each working before the next):**
> 1. **Data model + mock service** — Vendor (golden record) with the 4 IDs, status, segment, risk, AVL, block state, documents, performance, timeline. Implement the business rules (below) as pure functions with unit tests.
> 2. **Vendor 360 list** — searchable/filterable table with status/segment/risk/AVL/block badges; bulk-safe, fast.
> 3. **Vendor detail (Supplier 360)** — tabbed: Overview · Identity & IDs · Diligence · Segmentation · Performance & CAPA · Risk · Blocks · Documents · Activity.
> 4. **Onboarding wizard** — tiered stepper (Company Profile → Tax Registrations → Sites & Contacts → Banking → Qualification → Documents → Declarations & Submit), dual-entry, staged diligence, ID reconciliation states, "no ANID ⇒ no PO" gate.
> 5. **Segmentation** (scored) · **AVL** (auto-status) · **Admin/Blocking** (scenario matrix + propagation) · **VPE + CAPA** · **Risk profiling** · minimal **Settings** (per-BU thresholds).
>
> Confirm the stack and the module's route/placement with me, then start with slice 1. Match the product theme exactly (see design spec below). Ask before large architectural choices; otherwise proceed and show working slices.

---

## Design theme (from live demo.aerchain.io)

- **Light theme**, near-white background; **violet/purple primary** (~`#6d28d9`/`#7c3aed`), green success, amber "in-progress", red danger.
- Font: Montserrat-style sans. Rounded corners (8–14px), soft shadows, generous whitespace.
- **Top nav:** AERCHAIN logo, "Modules" dropdown, "Aiera" (the AI copilot), search, notifications, settings gear, "Live" status pill, user chip.
- **Patterns:** horizontal **tiered stepper** with filled purple check-circles + "Tier N" subtitles; **pill badges** (e.g. `Onboarding`, `In Progress`); section headers with a coloured rounded icon-chip; clean **modals** (e.g. "Add Site" with form grid + Cancel/purple Save); **purple toggles**; primary CTA `Save & Continue →`; an `Auto-Fill Demo` helper button; progress bar ("100% complete"); mono chips for GST/IDs.
- Reference images: the four `screencapture-demo-aerchain-io-vendor-onboard-*.png` files (attach at least one).

## Identity & data model (the golden record)

Reconcile four IDs on one **Aerchain Vendor ID** (`AER-VND-*`, golden record):
- **SM Vendor ID** (SLP, `S…`) — assigned at first touch.
- **ANID** (SAP Business Network) — issued when the supplier activates its account.
- **LIFNR** (SAP ERP Vendor Master via MDG-S/CIG) — created at award.

Staged onboarding, dual entry (Aerchain-led via Supplier Invite API + auto Trading-Relationship-Request, or Ariba-led legacy). Light diligence → bid-eligible; deep diligence/TPDD → SAP master at award. Integrations: SAP Business Network (Supplier Invite API), Ariba SLP (read/write + "pre-approved for sourcing"), MDG-S via CIG, SAP ECC/S4, ServiceNow, file fallback.

## Business rules to encode (from the PRD catalogue)

- **BR-01 No-ANID-no-PO:** a supplier without a valid ANID cannot have a PO issued.
- **BR-02 Performance→status:** score >70 → **AVL**; 50–70 → **Qualified**; <50 → **Qualified + CAPA**.
- **BR-03 Rating band:** 0–50 Poor · 51–85 Satisfactory · 86+ Excellent.
- **BR-04 Segmentation:** score >4 Strategic · ≤4 & >2 Essential · ≤2 Transactional; risk = Criticality × Complexity → High/Med/Low.
- **BR-05 Review cadence:** Strategic quarterly · Essential half-yearly · Transactional annually.
- **BR-06 Block scenario matrix** (Sourcing / Purchasing / Payment):
  - New/Registered → Sourcing on; Purchasing/Payment N/A
  - Incumbent→Registered → all three on (if no open order)
  - Qualified (good) → all off
  - Qualified poor-perf → Sourcing on, Purchasing on (if no open order), Payment on
  - Blacklisting → all three on
- **BR-07** 18-month inactivity → conditional block. **BR-08** Blacklist = CEO/AIIL approval, group-wide. **BR-09** ≥3 quotes (with exception list). **BR-10** VPE triggers (12m expiry, project closure, within 12m of PO/SO, on-demand, CAPA done, blacklist/whitelist req). **BR-11** CAPA finalised within 3 months for Poor. **BR-12** every block/unblock needs a VPE notification input. **BR-13** conditional block eliminates new POs but preserves open POs.

## Product constraints

- Spelling is **"Aerchain"** (lowercase c). The AI copilot is **"Aiera"**.
- Use the app's **existing icon set** (not emojis) and existing components.
- Keep it **real and working** (state + rules + mock service), not a static mock.

---

## Attachments to give the new session (all in the `aerchain-assets` repo)

| File | What it is / why |
|---|---|
| `Aerchain-Adani-Supplier-Sourcing-PRD.html` | **Primary build spec** — 86 FRs + acceptance criteria, business rules, UC1–30, data model, integrations, NFRs. |
| `Aerchain-Adani-Process-Blueprint.html` | As-Is vs To-Be process maps (all vendor + sourcing flows, validation gates). |
| `adani-ariba-integration-technical.html` | Identity/golden-record model, staged onboarding, integration surfaces, field mapping. |
| `Adani-RFP-Requirements-Aerchain-Positioning-Matrix-FINAL.html` | Requirement → Aerchain capability mapping (streams 1.1–2.8). |
| `screencapture-demo-aerchain-io-vendor-onboard-*.png` (≥1) | **Exact visual theme** reference. |
| Original Adani RFP `.docx` (SoW … Supplier and Sourcing, V1) | Ultimate source of truth for wording/edge cases. |

(Optional broader context: `Aerchain-Adani-Proposal-Full-S2P.html`, `Aerchain-Adani-Business-Case.html`, `Aerchain-Adani-Tokenization-AI-Operating-Cost.html`.)

## Suggested first message to the fresh session

> Clone `gkg-aerchain/aerchain-s2p` (the live app — not the solution-map). Read the attached PRD, blueprint, integration brief and demo screenshots. Map the existing stack and design system, then propose where the Vendor Management module plugs in and build slice 1 (data model + rules + mock service) first. [attach the files above]
