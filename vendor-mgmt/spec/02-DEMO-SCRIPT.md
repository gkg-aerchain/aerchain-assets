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
