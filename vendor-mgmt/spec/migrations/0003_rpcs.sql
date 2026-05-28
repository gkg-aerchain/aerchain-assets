-- =============================================================================
-- Aerchain Vendor Management — 0003 RPCs (portal + invitation + onboarding glue)
-- These SECURITY DEFINER functions are the safe public/buyer entry points so we
-- never expose raw tables to anon. Depends on 0001, 0002.
-- =============================================================================

-- slug generator (url-safe, deduped per org)
create or replace function public.generate_vendor_slug(p_name text, p_org uuid) returns text
language plpgsql stable security definer set search_path = public as $$
declare base text; cand text; n int := 0;
begin
  base := regexp_replace(lower(coalesce(p_name,'vendor')), '[^a-z0-9]+', '-', 'g');
  base := trim(both '-' from left(base, 40));
  if base = '' then base := 'vendor'; end if;
  cand := base;
  while exists (select 1 from public.vendors where org_id = p_org and slug = cand) loop
    n := n + 1; cand := base || '-' || n;
  end loop;
  return cand;
end $$;

-- upsert the vendor_users row for the current auth user
create or replace function public.ensure_vendor_user(p_email text, p_full_name text default null)
returns uuid language plpgsql security definer set search_path = public as $$
declare vid uuid;
begin
  insert into public.vendor_users(auth_user_id, email, full_name)
  values (auth.uid(), lower(p_email), p_full_name)
  on conflict (email) do update set auth_user_id = excluded.auth_user_id,
       full_name = coalesce(public.vendor_users.full_name, excluded.full_name)
  returning id into vid;
  return vid;
end $$;
grant execute on function public.ensure_vendor_user(text,text) to authenticated, service_role;

-- BUYER: Add Prospect + Send Invitation  (one call)
create or replace function public.invite_vendor(
  p_org uuid, p_company text, p_category text,
  p_contact_name text, p_email text, p_phone text default null,
  p_designation text default null, p_source vendor_source default 'manual',
  p_source_ref text default null
) returns jsonb language plpgsql security definer set search_path = public as $$
declare v_slug text; v_id uuid; v_token text;
begin
  if not public.user_in_org(p_org) then
    raise exception 'not authorized for org %', p_org using errcode='insufficient_privilege';
  end if;

  v_slug := public.generate_vendor_slug(p_company, p_org);
  insert into public.vendors(org_id, slug, legal_name, primary_category, source, source_ref,
                             lifecycle_status, created_by)
  values (p_org, v_slug, p_company, p_category, p_source, p_source_ref, 'prospect', auth.uid())
  returning id into v_id;

  insert into public.vendor_contacts(vendor_id, full_name, email, phone, designation, role, is_primary, created_by)
  values (v_id, p_contact_name, lower(p_email), p_phone, p_designation, 'procurement', true, auth.uid());

  v_token := encode(gen_random_bytes(18), 'hex');
  insert into public.vendor_invitations(org_id, vendor_id, company_name, category, contact_name,
                                        email, phone, designation, token, status, source, source_ref, invited_by, created_by)
  values (p_org, v_id, p_company, p_category, p_contact_name, lower(p_email), p_phone, p_designation,
          v_token, 'pending', p_source, p_source_ref, auth.uid(), auth.uid());

  perform public.vendor_transition(v_id, 'invited', 'invitation sent');
  insert into public.vendor_audit_log(vendor_id, actor_id, action, payload)
  values (v_id, auth.uid(), 'invitation_sent', jsonb_build_object('email', lower(p_email), 'source', p_source));

  return jsonb_build_object('vendor_id', v_id, 'slug', v_slug, 'token', v_token);
end $$;
grant execute on function public.invite_vendor(uuid,text,text,text,text,text,text,vendor_source,text) to authenticated, service_role;

-- PUBLIC: look up an invitation by token (safe fields + org branding) — anon ok
create or replace function public.get_invitation(p_token text) returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare r record;
begin
  select i.company_name, i.category, i.contact_name, i.email, i.status, i.expires_at,
         o.id as org_id, o.name as org_name, o.portal_slug, o.logo_url, o.brand_primary, v.slug as vendor_slug
  into r
  from public.vendor_invitations i
  join public.organizations o on o.id = i.org_id
  left join public.vendors v on v.id = i.vendor_id
  where i.token = p_token;
  if not found then return jsonb_build_object('valid', false); end if;
  return jsonb_build_object('valid', r.status in ('pending'), 'company_name', r.company_name,
    'category', r.category, 'contact_name', r.contact_name, 'email', r.email, 'status', r.status,
    'expires_at', r.expires_at, 'org_id', r.org_id, 'org_name', r.org_name,
    'portal_slug', r.portal_slug, 'logo_url', r.logo_url, 'brand_primary', r.brand_primary,
    'vendor_slug', r.vendor_slug);
end $$;
grant execute on function public.get_invitation(text) to anon, authenticated, service_role;

-- PUBLIC: open self-registration from a buyer's portal ("Register now") — anon ok
create or replace function public.self_register(
  p_portal_slug text, p_company text, p_category text,
  p_name text, p_email text, p_phone text default null
) returns jsonb language plpgsql security definer set search_path = public as $$
declare v_org uuid; v_slug text; v_id uuid; v_token text;
begin
  select id into v_org from public.organizations where portal_slug = p_portal_slug;
  if v_org is null then raise exception 'unknown portal %', p_portal_slug; end if;

  v_slug := public.generate_vendor_slug(p_company, v_org);
  insert into public.vendors(org_id, slug, legal_name, primary_category, source, lifecycle_status)
  values (v_org, v_slug, p_company, p_category, 'self_registration', 'prospect')
  returning id into v_id;

  insert into public.vendor_contacts(vendor_id, full_name, email, phone, role, is_primary)
  values (v_id, p_name, lower(p_email), p_phone, 'procurement', true);

  v_token := encode(gen_random_bytes(18), 'hex');
  insert into public.vendor_invitations(org_id, vendor_id, company_name, category, contact_name,
                                        email, phone, token, status, source)
  values (v_org, v_id, p_company, p_category, p_name, lower(p_email), p_phone, v_token, 'pending', 'self_registration');

  perform public.vendor_transition(v_id, 'invited', 'self-registration');
  return jsonb_build_object('vendor_slug', v_slug, 'token', v_token, 'org_id', v_org);
end $$;
grant execute on function public.self_register(text,text,text,text,text,text) to anon, authenticated, service_role;

-- VENDOR: claim an invitation after auth (links user, creates membership, starts registering)
create or replace function public.claim_invitation(p_token text) returns jsonb
language plpgsql security definer set search_path = public as $$
declare i record; vu uuid;
begin
  select * into i from public.vendor_invitations where token = p_token for update;
  if not found then raise exception 'invalid token'; end if;
  if i.status <> 'pending' or i.expires_at < now() then raise exception 'invitation not claimable'; end if;

  vu := public.ensure_vendor_user(i.email, i.contact_name);
  insert into public.vendor_memberships(vendor_user_id, vendor_id, member_role, is_primary, created_by)
  values (vu, i.vendor_id, 'owner', true, auth.uid())
  on conflict (vendor_user_id, vendor_id) do nothing;

  update public.vendor_invitations set status = 'accepted', accepted_at = now() where id = i.id;

  -- move into registering (invited -> registering); ignore if already past
  begin perform public.vendor_transition(i.vendor_id, 'registering', 'vendor started registration');
  exception when others then null; end;

  return jsonb_build_object('vendor_id', i.vendor_id,
    'vendor_slug', (select slug from public.vendors where id = i.vendor_id),
    'org_id', i.org_id);
end $$;
grant execute on function public.claim_invitation(text) to authenticated, service_role;

-- VENDOR: compute required-document checklist for a vendor (fulfilled or not)
create or replace function public.vendor_document_checklist(p_vendor uuid)
returns table(requirement_key text, doc_type document_type, label text, is_mandatory boolean,
              fulfilled boolean, document_id uuid, status document_status, expires_at date)
language sql stable security definer set search_path = public as $$
  select r.requirement_key, r.doc_type, r.label, r.is_mandatory,
         d.id is not null as fulfilled, d.id, d.status, d.expires_at
  from public.document_requirements r
  left join public.vendor_documents d
    on d.vendor_id = p_vendor and d.requirement_key = r.requirement_key
  where (r.applies_category is null
         or r.applies_category = (select primary_category from public.vendors where id = p_vendor))
  order by r.sort_order;
$$;
grant execute on function public.vendor_document_checklist(uuid) to authenticated, service_role;
