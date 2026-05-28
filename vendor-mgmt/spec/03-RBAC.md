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
