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
