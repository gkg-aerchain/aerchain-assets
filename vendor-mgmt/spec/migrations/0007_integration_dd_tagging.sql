-- =============================================================================
-- Aerchain Vendor Management — 0007 ERP INTEGRATION + VENDOR TAGGING + DUE DILIGENCE
-- Adds: front-end-configurable integration connections, bi-directional vendor-master
-- sync bookkeeping, GRN metrics, OEM/dealer + preferred tagging, a configurable
-- due-diligence checklist with an approval gate, and master-data dedup candidates.
-- Depends on 0001..0006.
-- =============================================================================

do $$ begin
  create type erp_system            as enum ('sap_s4hana','sap_mdg','sap_ariba','coupa','oracle','baan_infor','generic_rest');
  create type integration_auth      as enum ('api_key','oauth2','basic','cert');
  create type sync_direction        as enum ('inbound','outbound');
  create type integration_run_status as enum ('running','success','partial','error');
  create type vendor_class          as enum ('oem','dealer','distributor','channel_partner','manufacturer','service_provider','other');
  create type dd_source             as enum ('api','ai','human','processunity');
  create type dd_status             as enum ('pending','pass','fail','manual_review','waived');
exception when duplicate_object then null; end $$;

-- ---------- vendor tagging (OEM vs dealer, preferred, brands) -----------------
alter table public.vendors add column if not exists vendor_class vendor_class not null default 'other';
alter table public.vendors add column if not exists is_preferred boolean not null default false;
alter table public.vendors add column if not exists brand_tags text[] not null default '{}';
alter table public.vendors add column if not exists parent_oem_id uuid references public.vendors(id) on delete set null;
create index if not exists idx_vendors_class on public.vendors(org_id, vendor_class);

-- ---------- integration connections (front-end configurable) -----------------
create table if not exists public.integration_connections (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references public.organizations(id) on delete cascade,
  system_type erp_system not null,
  name text not null,
  base_url text,
  environment text default 'sandbox',          -- 'sandbox' | 'prod'
  auth_type integration_auth not null default 'api_key',
  vault_secret_id uuid,                          -- Supabase Vault secret id (NEVER store creds plaintext)
  status text not null default 'unconfigured',   -- 'unconfigured'|'connected'|'error'
  last_test_at timestamptz,
  last_test_info jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_intconn_org on public.integration_connections(org_id);

create table if not exists public.integration_field_mappings (
  id uuid primary key default gen_random_uuid(),
  connection_id uuid not null references public.integration_connections(id) on delete cascade,
  entity text not null default 'vendor',         -- 'vendor' | 'grn'
  direction sync_direction not null default 'outbound',
  source_field text not null,                    -- AirChain field
  target_field text not null,                    -- ERP field (e.g. LIFNR/NAME1)
  transform text,                                -- optional expression/format note
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_fieldmap_conn on public.integration_field_mappings(connection_id);

create table if not exists public.vendor_external_refs (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid not null references public.vendors(id) on delete cascade,
  connection_id uuid references public.integration_connections(id) on delete set null,
  external_system erp_system not null,
  external_id text not null,                     -- LIFNR / SMVendorID
  last_synced_at timestamptz,
  sync_status text,
  sync_hash text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid,
  unique (vendor_id, external_system)
);
create index if not exists idx_extref_vendor on public.vendor_external_refs(vendor_id);

create table if not exists public.integration_sync_runs (
  id uuid primary key default gen_random_uuid(),
  connection_id uuid references public.integration_connections(id) on delete cascade,
  org_id uuid references public.organizations(id) on delete cascade,
  direction sync_direction not null,
  entity text not null default 'vendor',
  status integration_run_status not null default 'running',
  total_count int default 0, ok_count int default 0, failed_count int default 0,
  started_at timestamptz not null default now(),
  finished_at timestamptz,
  error text,
  triggered_by uuid,
  created_at timestamptz not null default now()
);
create index if not exists idx_syncrun_conn on public.integration_sync_runs(connection_id, started_at desc);

create table if not exists public.integration_sync_records (
  id uuid primary key default gen_random_uuid(),
  run_id uuid not null references public.integration_sync_runs(id) on delete cascade,
  vendor_id uuid references public.vendors(id) on delete set null,
  external_id text,
  action text,                                   -- create|update|skip|conflict
  status text,                                   -- ok|error
  payload jsonb,
  error text,
  created_at timestamptz not null default now()
);
create index if not exists idx_syncrec_run on public.integration_sync_records(run_id);

-- ---------- GRN / objective performance metrics (pulled from SAP) ------------
create table if not exists public.vendor_grn_metrics (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid not null references public.vendors(id) on delete cascade,
  period text,                                   -- 'FY2024-25' or 'Q1'
  on_time_delivery_pct numeric,
  quality_rejection_pct numeric,
  grn_count int,
  source_connection_id uuid references public.integration_connections(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_grn_vendor on public.vendor_grn_metrics(vendor_id);

-- ---------- due diligence: configurable checklist + per-vendor items ----------
create table if not exists public.due_diligence_checks (
  id uuid primary key default gen_random_uuid(),
  check_key text unique not null,                -- 'sanctions_ofac','gst_active',...
  label text not null,
  category text,                                 -- identity|tax|sanctions|financial|legal|reputation|physical|operational|aggregate
  provider text,                                 -- OFAC|GST portal|DNB|Equifax|ProcessUnity|AI|human
  default_source dd_source not null default 'api',
  is_mandatory boolean not null default false,
  applies_min_risk risk_level,                   -- null=all; else only when vendor risk >= this
  enabled boolean not null default true,
  sort_order int default 100,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);

create table if not exists public.vendor_due_diligence_items (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid not null references public.vendors(id) on delete cascade,
  check_key text not null,
  status dd_status not null default 'pending',
  source dd_source not null default 'api',
  result jsonb,
  evidence_document_id uuid references public.vendor_documents(id) on delete set null,
  performed_by uuid,
  performed_at timestamptz,
  note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid,
  unique (vendor_id, check_key)
);
create index if not exists idx_dd_vendor on public.vendor_due_diligence_items(vendor_id);

-- ---------- master-data dedup candidates -------------------------------------
create table if not exists public.vendor_duplicate_candidates (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid not null references public.vendors(id) on delete cascade,
  match_vendor_id uuid not null references public.vendors(id) on delete cascade,
  score numeric,                                 -- 0..1 similarity
  reason text,
  status text not null default 'open',           -- open|merged|dismissed
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_dupe_vendor on public.vendor_duplicate_candidates(vendor_id);

-- ---------- triggers (updated_at + created_by) for new tables -----------------
do $$
declare t text;
begin
  foreach t in array array[
    'integration_connections','integration_field_mappings','vendor_external_refs',
    'vendor_grn_metrics','due_diligence_checks','vendor_due_diligence_items',
    'vendor_duplicate_candidates'
  ] loop
    execute format('drop trigger if exists set_updated_at on public.%I;', t);
    execute format('create trigger set_updated_at before update on public.%I for each row execute function public.tg_set_updated_at();', t);
    execute format('drop trigger if exists set_created_by on public.%I;', t);
    execute format('create trigger set_created_by before insert on public.%I for each row execute function public.tg_set_created_by();', t);
  end loop;
end $$;

-- ---------- DD gate helper + guarded approve RPC ------------------------------
-- Returns whether all mandatory DD checks (for the vendor's risk tier) have passed.
create or replace function public.dd_gate_status(p_vendor uuid) returns jsonb
language sql stable security definer set search_path = public as $$
  with applicable as (
    select c.check_key, c.is_mandatory
    from public.due_diligence_checks c
    where c.enabled
      and (c.applies_min_risk is null
           or (select risk_level from public.vendors where id = p_vendor) >= c.applies_min_risk)
  ),
  items as (
    select a.check_key, a.is_mandatory,
           coalesce(d.status, 'pending')::text as status
    from applicable a
    left join public.vendor_due_diligence_items d
      on d.vendor_id = p_vendor and d.check_key = a.check_key
  )
  select jsonb_build_object(
    'mandatory_total', count(*) filter (where is_mandatory),
    'mandatory_passed', count(*) filter (where is_mandatory and status in ('pass','waived')),
    'passed', count(*) filter (where is_mandatory and status not in ('pass','waived')) = 0
  ) from items;
$$;
grant execute on function public.dd_gate_status(uuid) to authenticated, service_role;

-- Approve a vendor only if the DD gate passes (or is explicitly waived).
create or replace function public.approve_vendor(p_vendor uuid, p_note text default null, p_waive boolean default false)
returns public.vendors
language plpgsql security definer set search_path = public as $$
declare gate jsonb; v public.vendors;
begin
  if not public.is_buyer_for_vendor(p_vendor) then
    raise exception 'not authorized' using errcode='insufficient_privilege';
  end if;
  gate := public.dd_gate_status(p_vendor);
  if not (gate->>'passed')::boolean and not p_waive then
    raise exception 'due diligence not complete: %', gate using errcode='check_violation';
  end if;

  insert into public.vendor_approvals(vendor_id, decision, approver_id, note, due_diligence_passed, decided_at, created_by)
  values (p_vendor, 'approved', auth.uid(), p_note, (gate->>'passed')::boolean, now(), auth.uid());

  v := public.vendor_transition(p_vendor, 'approved', coalesce(p_note,'approved'));
  perform public.vendor_transition(p_vendor, 'active', 'activated');  -- approved -> active
  -- NOTE: client (or pg_net hook) then calls erp-sync action:'push' for each connection.
  return v;
end $$;
grant execute on function public.approve_vendor(uuid, text, boolean) to authenticated, service_role;

-- =============================================================================
-- GRANTS + RLS for new tables
-- =============================================================================
do $$
declare t text;
begin
  foreach t in array array[
    'integration_connections','integration_field_mappings','vendor_external_refs',
    'integration_sync_runs','integration_sync_records','vendor_grn_metrics',
    'due_diligence_checks','vendor_due_diligence_items','vendor_duplicate_candidates'
  ] loop
    execute format('grant select, insert, update, delete on public.%I to authenticated, service_role;', t);
    execute format('alter table public.%I enable row level security;', t);
  end loop;
end $$;

-- integration config: buyer_admin within the org
drop policy if exists intconn_rw on public.integration_connections;
create policy intconn_rw on public.integration_connections for all to authenticated
  using (public.user_in_org(org_id) and has_role(auth.uid(),'buyer_admin'))
  with check (public.user_in_org(org_id) and has_role(auth.uid(),'buyer_admin'));

drop policy if exists fieldmap_rw on public.integration_field_mappings;
create policy fieldmap_rw on public.integration_field_mappings for all to authenticated
  using (exists (select 1 from public.integration_connections c where c.id = connection_id
                 and public.user_in_org(c.org_id) and has_role(auth.uid(),'buyer_admin')))
  with check (exists (select 1 from public.integration_connections c where c.id = connection_id
                 and public.user_in_org(c.org_id) and has_role(auth.uid(),'buyer_admin')));

-- sync runs/records: buyer org can read (writes via service role)
drop policy if exists syncrun_read on public.integration_sync_runs;
create policy syncrun_read on public.integration_sync_runs for select to authenticated
  using (public.user_in_org(org_id));
drop policy if exists syncrec_read on public.integration_sync_records;
create policy syncrec_read on public.integration_sync_records for select to authenticated
  using (exists (select 1 from public.integration_sync_runs r where r.id = run_id and public.user_in_org(r.org_id)));

-- vendor-scoped buyer-internal tables
drop policy if exists extref_rw on public.vendor_external_refs;
create policy extref_rw on public.vendor_external_refs for all to authenticated
  using (public.is_buyer_for_vendor(vendor_id)) with check (public.is_buyer_for_vendor(vendor_id));

drop policy if exists grn_rw on public.vendor_grn_metrics;
create policy grn_rw on public.vendor_grn_metrics for all to authenticated
  using (public.is_buyer_for_vendor(vendor_id)) with check (public.is_buyer_for_vendor(vendor_id));

drop policy if exists dd_items_rw on public.vendor_due_diligence_items;
create policy dd_items_rw on public.vendor_due_diligence_items for all to authenticated
  using (public.is_buyer_for_vendor(vendor_id)) with check (public.is_buyer_for_vendor(vendor_id));

drop policy if exists dupe_rw on public.vendor_duplicate_candidates;
create policy dupe_rw on public.vendor_duplicate_candidates for all to authenticated
  using (public.is_buyer_for_vendor(vendor_id)) with check (public.is_buyer_for_vendor(vendor_id));

-- DD checklist config: all authenticated read; buyer_admin write
drop policy if exists ddchecks_read on public.due_diligence_checks;
create policy ddchecks_read on public.due_diligence_checks for select to authenticated using (true);
drop policy if exists ddchecks_write on public.due_diligence_checks;
create policy ddchecks_write on public.due_diligence_checks for all to authenticated
  using (has_role(auth.uid(),'buyer_admin')) with check (has_role(auth.uid(),'buyer_admin'));

-- ---------- realtime for live sync/DD progress -------------------------------
alter publication supabase_realtime add table public.integration_sync_runs;
alter publication supabase_realtime add table public.vendor_due_diligence_items;
alter table public.integration_sync_runs replica identity full;
alter table public.vendor_due_diligence_items replica identity full;

-- ---------- seed: the configurable DD checklist (the "30-40 checks") ----------
insert into public.due_diligence_checks (check_key, label, category, provider, default_source, is_mandatory, applies_min_risk, sort_order) values
 ('pan_verify','PAN Verification','identity','Income-Tax/NSDL','api',true,null,10),
 ('gst_active','GST Registration Active','tax','GST Portal','api',true,null,20),
 ('msme_status','MSME / Udyam Status','tax','Udyam Portal','api',false,null,30),
 ('sanctions_ofac','OFAC Sanctions','sanctions','OpenSanctions/OFAC','api',true,null,40),
 ('sanctions_un_eu','UN / EU Sanctions','sanctions','OpenSanctions','api',true,null,50),
 ('pep_screen','PEP Screening','sanctions','OpenSanctions','api',true,null,60),
 ('debarment_check','Debarment / Blacklist','compliance','Sectoral lists','api',false,null,70),
 ('credit_dnb','D&B Credit Check','financial','Dun & Bradstreet','api',false,'medium',80),
 ('credit_equifax','Equifax Credit Check','financial','Equifax','api',false,'medium',90),
 ('litigation_scan','Litigation Scan','legal','AI + court/news','ai',false,'medium',100),
 ('adverse_media','Adverse Media','reputation','News + AI','ai',false,null,110),
 ('financial_health','Financial Health','financial','Filings + AI','ai',false,null,120),
 ('site_verification','Physical Site Verification','physical','Human recording','human',false,'high',130),
 ('reference_check','Client Reference Check','operational','Human recording','human',false,null,140),
 ('processunity_score','ProcessUnity DD Score','aggregate','ProcessUnity','processunity',false,null,150)
on conflict (check_key) do nothing;
