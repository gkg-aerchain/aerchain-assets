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
