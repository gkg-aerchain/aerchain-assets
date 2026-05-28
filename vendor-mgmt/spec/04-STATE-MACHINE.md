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
