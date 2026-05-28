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
