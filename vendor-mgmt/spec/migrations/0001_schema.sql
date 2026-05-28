-- =============================================================================
-- Aerchain Vendor Management — 0001 SCHEMA (enums + tables + grants + enable RLS)
-- Apply as a single Supabase migration. RLS POLICIES are in 0004_rls.sql.
-- Conventions: public schema; no FK to auth.users; created_at/updated_at/created_by
-- on every table; gen_random_uuid() PKs. Idempotent-safe where practical.
-- =============================================================================

create extension if not exists pgcrypto;

-- ----------------------------------------------------------------------------
-- ENUMS
-- ----------------------------------------------------------------------------
do $$ begin
  create type org_type              as enum ('buyer','platform');
  create type vendor_lifecycle      as enum ('prospect','invited','registering','submitted','under_review','approved','active','rejected','blocked','inactive');
  create type vendor_tier           as enum ('strategic','preferred','approved','conditional','unclassified');
  create type risk_level            as enum ('low','medium','high','critical','unrated');
  create type vendor_source         as enum ('manual','rfx_event','self_registration');
  create type tax_type              as enum ('gstin','iec','pan','tan','vat','other');
  create type site_type             as enum ('office','factory','warehouse','hub','branch','rnd','other');
  create type contact_role          as enum ('sales','accounts','finance','logistics','procurement','management','technical','other');
  create type bank_scope            as enum ('domestic','international');
  create type document_status       as enum ('pending','uploaded','verified','rejected','expired');
  create type document_type         as enum ('pan_card','gst_certificate','incorporation_certificate','iso_9001','iso_14001','iso_27001','insurance','bank_proof','msa','material_test_certificate','msme_certificate','financial_statement','authorization_letter','other');
  create type approval_decision     as enum ('pending','approved','rejected','changes_requested');
  create type scorecard_status      as enum ('draft','in_progress','complete');
  create type scorecard_dimension   as enum ('financial_health','compliance_standing','operational_capability','geographic_risk','information_security','esg_sustainability');
  create type screening_type        as enum ('sanctions','pep','credit','news','geographic','adverse_media');
  create type screening_status      as enum ('clean','flagged','pending','error');
  create type invitation_status     as enum ('pending','accepted','expired','revoked');
  create type message_author_type   as enum ('buyer','vendor','system');
  create type po_status             as enum ('draft','issued','acknowledged','delivered','invoiced','paid','cancelled');
  create type notification_type     as enum (
    'invitation_sent','registration_started','registration_submitted','approval_needed',
    'vendor_approved','vendor_rejected','changes_requested','document_expiring','document_rejected',
    'message_received','screening_complete','evaluation_assigned','reupload_reminder',
    'vendor_blocked','vendor_unblocked');
exception when duplicate_object then null; end $$;

-- ----------------------------------------------------------------------------
-- ORGANIZATIONS (buyer tenants; Adani is the demo tenant). Idempotent create.
-- ----------------------------------------------------------------------------
create table if not exists public.organizations (
  id            uuid primary key default gen_random_uuid(),
  name          text not null,
  slug          text unique not null,
  org_type      org_type not null default 'buyer',
  portal_slug   text unique,                 -- /portal/:portal_slug   (e.g. 'adani')
  logo_url      text,
  brand_primary text,                         -- hex/token override for the portal
  brand_accent  text,
  website       text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  created_by    uuid
);

-- ----------------------------------------------------------------------------
-- VENDORS  (org-scoped relationship + legal-entity profile; Tier 2 of hierarchy)
-- ----------------------------------------------------------------------------
create table if not exists public.vendors (
  id                  uuid primary key default gen_random_uuid(),
  org_id              uuid not null references public.organizations(id) on delete cascade,
  slug                text not null,                     -- routes /vendors/:slug  (e.g. 'ent-1')
  -- identity
  legal_name          text not null,
  trade_name          text,
  group_name          text,                              -- Tier 1 (e.g. 'Tata Group')
  vendor_code         text,                              -- assigned at approval (e.g. 'TATA-STL')
  pan                 text,
  cin                 text,
  entity_type         text,                              -- 'Public Limited', etc.
  incorporation_date  date,
  website             text,
  primary_category    text,                              -- 'Raw Materials', etc.
  business_description text,
  -- registered address (legal entity)
  addr_line1          text, addr_line2 text, city text, state text, pincode text, country text default 'India',
  -- MSME
  msme_registered     boolean not null default false,
  msme_number         text,
  -- lifecycle + classification
  lifecycle_status    vendor_lifecycle not null default 'prospect',
  tier                vendor_tier not null default 'unclassified',
  risk_level          risk_level not null default 'unrated',
  source              vendor_source not null default 'manual',
  source_ref          text,                              -- RFQ number when source=rfx_event
  -- workflow timestamps
  onboarding_due_at   timestamptz,
  registration_progress int not null default 0,          -- 0..100 (wizard)
  submitted_at        timestamptz,
  approved_at         timestamptz,
  approved_by         uuid,
  -- rollups (denormalized for list/badges; kept fresh by triggers/edge fns)
  composite_score     numeric,
  total_spend         numeric default 0,
  po_count            int default 0,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  created_by          uuid,
  unique (org_id, slug)
);
create index if not exists idx_vendors_org           on public.vendors(org_id);
create index if not exists idx_vendors_status         on public.vendors(org_id, lifecycle_status);
create index if not exists idx_vendors_pan            on public.vendors(pan);

-- ----------------------------------------------------------------------------
-- TAX REGISTRATIONS  (Tier 3 — GSTIN / IEC per jurisdiction)
-- ----------------------------------------------------------------------------
create table if not exists public.vendor_tax_registrations (
  id                 uuid primary key default gen_random_uuid(),
  vendor_id          uuid not null references public.vendors(id) on delete cascade,
  tax_type           tax_type not null default 'gstin',
  registration_number text not null,
  jurisdiction       text,                 -- 'Maharashtra'
  jurisdiction_code  text,                 -- '27'
  status             text not null default 'active',
  addr_line1 text, addr_line2 text, city text, state text, pincode text, country text default 'India',
  is_primary         boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_taxreg_vendor on public.vendor_tax_registrations(vendor_id);

-- ----------------------------------------------------------------------------
-- SITES  (Tier 4 — nested under a tax registration, or entity-wide)
-- ----------------------------------------------------------------------------
create table if not exists public.vendor_sites (
  id                  uuid primary key default gen_random_uuid(),
  vendor_id           uuid not null references public.vendors(id) on delete cascade,
  tax_registration_id uuid references public.vendor_tax_registrations(id) on delete set null,
  site_name           text not null,
  site_code           text,                 -- auto-generated
  site_type           site_type not null default 'office',
  addr_line1 text, addr_line2 text, city text, state text, pincode text, country text default 'India',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_sites_vendor on public.vendor_sites(vendor_id);

-- ----------------------------------------------------------------------------
-- CONTACTS  (entity-wide when tax_registration_id is null; else scoped)
-- ----------------------------------------------------------------------------
create table if not exists public.vendor_contacts (
  id                  uuid primary key default gen_random_uuid(),
  vendor_id           uuid not null references public.vendors(id) on delete cascade,
  tax_registration_id uuid references public.vendor_tax_registrations(id) on delete set null,
  full_name           text not null,
  email               text,
  phone               text,
  designation         text,
  role                contact_role not null default 'other',
  is_primary          boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_contacts_vendor on public.vendor_contacts(vendor_id);

-- ----------------------------------------------------------------------------
-- DIRECTORS / SIGNATORIES  (manual or MCA auto-fetch)
-- ----------------------------------------------------------------------------
create table if not exists public.vendor_directors (
  id          uuid primary key default gen_random_uuid(),
  vendor_id   uuid not null references public.vendors(id) on delete cascade,
  full_name   text not null,
  din         text,
  designation text,
  source      text not null default 'manual',   -- 'manual' | 'mca'
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_directors_vendor on public.vendor_directors(vendor_id);

-- ----------------------------------------------------------------------------
-- DOCUMENT REQUIREMENTS (config: what docs are required by category/tier)
-- ----------------------------------------------------------------------------
create table if not exists public.document_requirements (
  id             uuid primary key default gen_random_uuid(),
  requirement_key text unique not null,         -- 'pan','bank_proof','iso_9001','gst:<state>'
  doc_type       document_type not null,
  label          text not null,
  applies_category text,                          -- null = all categories
  applies_tier   vendor_tier,                     -- null = all tiers
  is_mandatory   boolean not null default true,
  per_tax_registration boolean not null default false,  -- e.g. GST cert per state
  sort_order     int not null default 100,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);

-- ----------------------------------------------------------------------------
-- DOCUMENTS (uploaded files; Supabase Storage path; expiry tracking; AI extract)
-- ----------------------------------------------------------------------------
create table if not exists public.vendor_documents (
  id              uuid primary key default gen_random_uuid(),
  vendor_id       uuid not null references public.vendors(id) on delete cascade,
  doc_type        document_type not null default 'other',
  requirement_key text,                          -- which required slot this fills
  label           text,
  status          document_status not null default 'pending',
  storage_path    text,                          -- bucket 'vendor-documents'
  file_name       text,
  mime_type       text,
  size_bytes      bigint,
  issuer          text,                          -- e.g. 'Bureau Veritas'
  issue_date      date,
  expires_at      date,                          -- powers expiry alerts/reminders
  cert_number     text,
  linked_tax_registration_id uuid references public.vendor_tax_registrations(id) on delete set null,
  extracted_data  jsonb,                         -- AI extraction output
  uploaded_at     timestamptz,
  verified_by     uuid,
  verified_at     timestamptz,
  reminder_sent_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_docs_vendor   on public.vendor_documents(vendor_id);
create index if not exists idx_docs_expiry    on public.vendor_documents(expires_at) where expires_at is not null;

-- ----------------------------------------------------------------------------
-- BANK ACCOUNTS  (domestic IFSC / international SWIFT+IBAN)
-- ----------------------------------------------------------------------------
create table if not exists public.vendor_bank_accounts (
  id                  uuid primary key default gen_random_uuid(),
  vendor_id           uuid not null references public.vendors(id) on delete cascade,
  scope               bank_scope not null default 'domestic',
  account_holder_name text,
  account_number      text,                       -- store full; expose masked via view/policy
  account_type        text default 'Current Account',
  currency            text default 'INR',
  bank_name           text,
  branch              text,
  ifsc                text,                        -- domestic
  swift_bic           text,                        -- international
  iban                text,                        -- international
  intermediary_bank   text,
  intermediary_swift  text,
  is_primary          boolean not null default false,
  verification_document_id uuid references public.vendor_documents(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_bank_vendor on public.vendor_bank_accounts(vendor_id);

-- ----------------------------------------------------------------------------
-- QUALIFICATION (1:1) — financials, capability, infosec, ESG
-- ----------------------------------------------------------------------------
create table if not exists public.vendor_qualification (
  vendor_id            uuid primary key references public.vendors(id) on delete cascade,
  turnover_y1          numeric, turnover_y1_label text,
  turnover_y2          numeric, turnover_y2_label text,
  turnover_y3          numeric, turnover_y3_label text,
  net_worth            numeric,
  profitability_status text,
  auditor              text,
  fy_ends_in           text,
  years_experience     int,
  employee_count       int,
  manufacturing_capacity text,
  total_annual_capacity  text,
  quality_system       text,
  -- information security flags
  iso27001             boolean default false,
  soc2                 boolean default false,
  data_encryption      boolean default false,
  incident_response    boolean default false,
  bcp_dr               boolean default false,
  -- ESG
  environmental_policy boolean default false,
  sustainability_certs text[] default '{}',
  diversity_status     text[] default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);

-- ----------------------------------------------------------------------------
-- CLIENT REFERENCES  +  CERTIFICATIONS
-- ----------------------------------------------------------------------------
create table if not exists public.vendor_references (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid not null references public.vendors(id) on delete cascade,
  company_name text, contact_name text, contact_email text, contact_phone text,
  project_description text, value_range text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_refs_vendor on public.vendor_references(vendor_id);

create table if not exists public.vendor_certifications (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid not null references public.vendors(id) on delete cascade,
  cert_type text,             -- 'ISO 9001 (Quality)'
  issuer text,                -- 'Bureau Veritas'
  valid_until date,
  cert_number text,
  document_id uuid references public.vendor_documents(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_certs_vendor on public.vendor_certifications(vendor_id);

-- ----------------------------------------------------------------------------
-- INVITATIONS  (creates a prospect vendor row + token)
-- ----------------------------------------------------------------------------
create table if not exists public.vendor_invitations (
  id            uuid primary key default gen_random_uuid(),
  org_id        uuid not null references public.organizations(id) on delete cascade,
  vendor_id     uuid references public.vendors(id) on delete set null,
  company_name  text not null,
  category      text,
  contact_name  text,
  email         text not null,
  phone         text,
  designation   text,
  token         text unique not null,
  status        invitation_status not null default 'pending',
  source        vendor_source not null default 'manual',
  source_ref    text,
  invited_by    uuid,
  accepted_at   timestamptz,
  expires_at    timestamptz not null default (now() + interval '30 days'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_inv_token on public.vendor_invitations(token);
create index if not exists idx_inv_org   on public.vendor_invitations(org_id);

-- ----------------------------------------------------------------------------
-- STATUS HISTORY + APPROVALS
-- ----------------------------------------------------------------------------
create table if not exists public.vendor_status_history (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid not null references public.vendors(id) on delete cascade,
  from_status vendor_lifecycle,
  to_status   vendor_lifecycle not null,
  actor_id    uuid,
  reason      text,
  at          timestamptz not null default now()
);
create index if not exists idx_status_hist_vendor on public.vendor_status_history(vendor_id, at desc);

create table if not exists public.vendor_approvals (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid not null references public.vendors(id) on delete cascade,
  decision approval_decision not null default 'pending',
  approver_id uuid,
  note text,
  due_diligence_passed boolean,
  decided_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_appr_vendor on public.vendor_approvals(vendor_id);

-- ----------------------------------------------------------------------------
-- EVALUATION / SCORECARDS
-- ----------------------------------------------------------------------------
create table if not exists public.vendor_scorecards (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid not null references public.vendors(id) on delete cascade,
  name text not null default 'Vendor Evaluation',
  status scorecard_status not null default 'draft',
  scope scorecard_dimension[] default '{}',
  composite_score numeric,
  risk_level risk_level default 'unrated',
  evaluator_id uuid,
  evaluator_name text,
  evaluator_email text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_scorecard_vendor on public.vendor_scorecards(vendor_id);

create table if not exists public.vendor_scorecard_lines (
  id uuid primary key default gen_random_uuid(),
  scorecard_id uuid not null references public.vendor_scorecards(id) on delete cascade,
  dimension scorecard_dimension not null,
  dimension_weight numeric not null default 0,   -- e.g. 0.20
  criterion text not null,
  score int,                                      -- 1..5 (null = not scored)
  data_source text,                               -- 'Sanctions Screening API', etc.
  basis text,                                     -- rubric / rationale
  ai_suggested boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_scoreline_card on public.vendor_scorecard_lines(scorecard_id);

-- ----------------------------------------------------------------------------
-- RISK SCREENINGS  (sanctions/pep/credit/news/geographic)
-- ----------------------------------------------------------------------------
create table if not exists public.vendor_risk_screenings (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid not null references public.vendors(id) on delete cascade,
  screening_type screening_type not null,
  status screening_status not null default 'pending',
  result jsonb,
  entities_checked int default 0,
  hits int default 0,
  provider text,
  mode text not null default 'mock',   -- 'mock' | 'live'
  checked_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_screen_vendor on public.vendor_risk_screenings(vendor_id);

-- ----------------------------------------------------------------------------
-- WEB INSIGHTS (1:1 cache) + NEWS ITEMS
-- ----------------------------------------------------------------------------
create table if not exists public.vendor_web_insights (
  vendor_id uuid primary key references public.vendors(id) on delete cascade,
  overview text,
  headquarters text, founded text, employees text, revenue text, industry text,
  stock_ticker text, website text,
  market_cap text, credit_rating text, credit_agency text, dnb_rating text,
  key_ratios jsonb, key_personnel jsonb, financial_snapshot jsonb,
  mca_filings jsonb, gst_filing jsonb,
  sanctions_status text, pep_status text, ratings jsonb,
  refreshed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);

create table if not exists public.vendor_news_items (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid not null references public.vendors(id) on delete cascade,
  title text not null, source text, url text,
  published_at date,
  sentiment text,            -- 'positive' | 'negative' | 'neutral'
  summary text,
  created_at timestamptz not null default now()
);
create index if not exists idx_news_vendor on public.vendor_news_items(vendor_id, published_at desc);

-- ----------------------------------------------------------------------------
-- MESSAGES (buyer <-> vendor thread) + NOTIFICATIONS + AUDIT
-- ----------------------------------------------------------------------------
create table if not exists public.vendor_messages (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid not null references public.vendors(id) on delete cascade,
  author_type message_author_type not null,
  author_id uuid,
  author_name text,
  body text not null,
  attachment_document_id uuid references public.vendor_documents(id) on delete set null,
  read_by_buyer boolean not null default false,
  read_by_vendor boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_msg_vendor on public.vendor_messages(vendor_id, created_at);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  recipient_id uuid not null,             -- auth uid of recipient
  org_id uuid,
  vendor_id uuid references public.vendors(id) on delete cascade,
  type notification_type not null,
  title text not null,
  body text,
  link text,
  read boolean not null default false,
  created_at timestamptz not null default now()
);
create index if not exists idx_notif_recipient on public.notifications(recipient_id, read, created_at desc);

create table if not exists public.vendor_audit_log (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid references public.vendors(id) on delete cascade,
  actor_id uuid,
  action text not null,
  payload jsonb,
  at timestamptz not null default now()
);
create index if not exists idx_audit_vendor on public.vendor_audit_log(vendor_id, at desc);

-- ----------------------------------------------------------------------------
-- VENDOR USERS + MEMBERSHIPS  (vendor user -> many vendor (customer) records)
-- ----------------------------------------------------------------------------
create table if not exists public.vendor_users (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid unique,               -- maps to auth.uid(); NO fk to auth.users
  email text unique not null,
  full_name text,
  phone text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);

create table if not exists public.vendor_memberships (
  id uuid primary key default gen_random_uuid(),
  vendor_user_id uuid not null references public.vendor_users(id) on delete cascade,
  vendor_id uuid not null references public.vendors(id) on delete cascade,
  member_role text not null default 'owner',   -- 'owner' | 'member'
  is_primary boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid,
  unique (vendor_user_id, vendor_id)
);
create index if not exists idx_membership_user   on public.vendor_memberships(vendor_user_id);
create index if not exists idx_membership_vendor on public.vendor_memberships(vendor_id);

-- ----------------------------------------------------------------------------
-- PURCHASE ORDERS (shared between buyer Business-Overview + vendor PO views)
-- ----------------------------------------------------------------------------
create table if not exists public.purchase_orders (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid not null references public.vendors(id) on delete cascade,
  org_id uuid not null references public.organizations(id) on delete cascade,
  po_number text not null,
  title text,
  category text,
  amount numeric not null default 0,
  currency text default 'INR',
  status po_status not null default 'issued',
  order_date date,
  delivery_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid
);
create index if not exists idx_po_vendor on public.purchase_orders(vendor_id, order_date desc);

create table if not exists public.purchase_order_lines (
  id uuid primary key default gen_random_uuid(),
  po_id uuid not null references public.purchase_orders(id) on delete cascade,
  item text not null,
  quantity numeric, uom text, unit_price numeric, amount numeric,
  created_at timestamptz not null default now()
);
create index if not exists idx_poline_po on public.purchase_order_lines(po_id);

-- =============================================================================
-- GRANTS  (RLS still governs row visibility; these grant table-level access)
--   anon          : public portal (org branding, invitation token lookup, self-reg insert)
--   authenticated : buyer + vendor app users
--   service_role  : edge functions (bypass RLS)
-- =============================================================================
grant usage on schema public to anon, authenticated, service_role;

-- read-only for anon on public-portal-relevant tables
grant select on public.organizations to anon, authenticated, service_role;
grant select on public.vendor_invitations to anon, authenticated, service_role;
grant insert on public.vendor_invitations to anon;                   -- self-registration request
grant select, insert, update on public.vendors to anon, authenticated, service_role;

-- full CRUD for authenticated (rows filtered by RLS) + service_role
do $$
declare t text;
begin
  foreach t in array array[
    'vendor_tax_registrations','vendor_sites','vendor_contacts','vendor_directors',
    'document_requirements','vendor_documents','vendor_bank_accounts','vendor_qualification',
    'vendor_references','vendor_certifications','vendor_status_history','vendor_approvals',
    'vendor_scorecards','vendor_scorecard_lines','vendor_risk_screenings','vendor_web_insights',
    'vendor_news_items','vendor_messages','notifications','vendor_audit_log',
    'vendor_users','vendor_memberships','purchase_orders','purchase_order_lines','organizations','vendors'
  ] loop
    execute format('grant select, insert, update, delete on public.%I to authenticated, service_role;', t);
  end loop;
end $$;

-- =============================================================================
-- ENABLE ROW LEVEL SECURITY (policies defined in 0004_rls.sql)
-- =============================================================================
do $$
declare t text;
begin
  foreach t in array array[
    'organizations','vendors','vendor_tax_registrations','vendor_sites','vendor_contacts',
    'vendor_directors','document_requirements','vendor_documents','vendor_bank_accounts',
    'vendor_qualification','vendor_references','vendor_certifications','vendor_invitations',
    'vendor_status_history','vendor_approvals','vendor_scorecards','vendor_scorecard_lines',
    'vendor_risk_screenings','vendor_web_insights','vendor_news_items','vendor_messages',
    'notifications','vendor_audit_log','vendor_users','vendor_memberships',
    'purchase_orders','purchase_order_lines'
  ] loop
    execute format('alter table public.%I enable row level security;', t);
  end loop;
end $$;
