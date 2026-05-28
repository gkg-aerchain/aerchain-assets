-- =============================================================================
-- Aerchain Vendor Management — 0006 SEED
-- Populates Adani tenant with believable Indian B2B suppliers so the app looks
-- live on first load. Run AFTER 0001..0005. Auth users are linked at the bottom
-- (see DEMO USERS) once the auth accounts exist.
--
-- Monetary conventions: PO.amount in rupees; qualification turnover/net_worth in
-- CRORES (display fields). [A3]
-- =============================================================================

-- ---------- ORGS -------------------------------------------------------------
insert into public.organizations (id, name, slug, org_type, portal_slug, website, brand_primary) values
  ('00000000-0000-0000-0000-0000000000a0','Aerchain','aerchain','platform', null, 'https://aerchain.io', null),
  ('00000000-0000-0000-0000-0000000000a1','Adani Group','adani','buyer','adani','https://www.adani.com','#0a3d62')
on conflict (id) do nothing;

-- ---------- DOCUMENT REQUIREMENTS (the standard onboarding checklist) ---------
insert into public.document_requirements (requirement_key, doc_type, label, applies_category, is_mandatory, per_tax_registration, sort_order) values
  ('pan','pan_card','PAN Card', null, true, false, 10),
  ('coi','incorporation_certificate','Certificate of Incorporation', null, true, false, 20),
  ('gst','gst_certificate','GST Registration Certificate', null, true, true, 30),
  ('bank_proof','bank_proof','Bank Proof (cancelled cheque / letter)', null, true, false, 40),
  ('insurance','insurance','Insurance Certificate', null, true, false, 50),
  ('iso_9001','iso_9001','Quality Certificate (ISO 9001)', null, true, false, 60),
  ('iso_14001','iso_14001','Environmental Certificate (ISO 14001)', null, false, false, 70),
  ('material_test','material_test_certificate','Material Test Certificate','Raw Materials', true, false, 80),
  ('msa','msa','Master Service Agreement', null, false, false, 90)
on conflict (requirement_key) do nothing;

-- =============================================================================
-- VENDOR 1 — TATA STEEL (ent-1) — fully ACTIVE, full 360 depth
-- =============================================================================
insert into public.vendors (id, org_id, slug, legal_name, trade_name, group_name, vendor_code,
  pan, cin, entity_type, incorporation_date, website, primary_category, business_description,
  addr_line1, city, state, pincode, country, lifecycle_status, tier, risk_level, source,
  registration_progress, submitted_at, approved_at, composite_score, total_spend, po_count)
values ('00000000-0000-0000-0000-00000000e001','00000000-0000-0000-0000-0000000000a1','ent-1',
  'Tata Steel Limited','Tata Steel','Tata Group','TATA-STL',
  'AAACT2727Q','L27100MH1907PLC000260','Public Limited','1907-08-26','https://www.tatasteel.com',
  'Raw Materials','Leading global steel company with manufacturing operations in 26 countries.',
  'Bombay House, 24 Homi Modi Street','Mumbai','Maharashtra','400001','India',
  'active','strategic','low','manual',100, now()-interval '70 days', now()-interval '60 days',
  79, 452000000, 142)
on conflict (id) do nothing;

-- tax registrations (Tier 3)
insert into public.vendor_tax_registrations (id, vendor_id, tax_type, registration_number, jurisdiction, jurisdiction_code, status, addr_line1, city, state, pincode, is_primary) values
 ('00000000-0000-0000-0000-00000000f001','00000000-0000-0000-0000-00000000e001','gstin','27AAACT2727Q1ZV','Maharashtra','27','active','Bombay House, 24 Homi Modi Street','Mumbai','Maharashtra','400001',true),
 ('00000000-0000-0000-0000-00000000f002','00000000-0000-0000-0000-00000000e001','gstin','29AAACT2727Q1ZT','Karnataka','29','active','No. 12, Outer Ring Road, Marathahalli','Bangalore','Karnataka','560037',false),
 ('00000000-0000-0000-0000-00000000f003','00000000-0000-0000-0000-00000000e001','gstin','33AAACT2727Q1ZP','Tamil Nadu','33','active','Plot 45, SIPCOT Industrial Park, Gummidipoondi','Chennai','Tamil Nadu','601201',false),
 ('00000000-0000-0000-0000-00000000f004','00000000-0000-0000-0000-00000000e001','iec','0388001295','India (Nationwide)','IN','active','Bombay House','Mumbai','Maharashtra','400001',false)
on conflict (id) do nothing;

-- sites (Tier 4)
insert into public.vendor_sites (vendor_id, tax_registration_id, site_name, site_code, site_type, city, state) values
 ('00000000-0000-0000-0000-00000000e001','00000000-0000-0000-0000-00000000f001','Mumbai HQ','MUM-HQ','office','Mumbai','Maharashtra'),
 ('00000000-0000-0000-0000-00000000e001','00000000-0000-0000-0000-00000000f001','Jamshedpur Plant','JSR-PLT','factory','Jamshedpur','Jharkhand'),
 ('00000000-0000-0000-0000-00000000e001','00000000-0000-0000-0000-00000000f001','Pune Warehouse','PNQ-WH','warehouse','Pune','Maharashtra'),
 ('00000000-0000-0000-0000-00000000e001','00000000-0000-0000-0000-00000000f002','Bangalore Office','BLR-OFF','office','Bangalore','Karnataka'),
 ('00000000-0000-0000-0000-00000000e001','00000000-0000-0000-0000-00000000f002','Mysore Hub','MYS-HUB','hub','Mysore','Karnataka'),
 ('00000000-0000-0000-0000-00000000e001','00000000-0000-0000-0000-00000000f003','Chennai Branch','CHN-BR','branch','Chennai','Tamil Nadu');

-- contacts (entity-wide)
insert into public.vendor_contacts (vendor_id, full_name, email, phone, designation, role, is_primary) values
 ('00000000-0000-0000-0000-00000000e001','Rajesh Mehta','rajesh.mehta@tatasteel.com','+91 98765 43210','Key Account Manager','sales',true),
 ('00000000-0000-0000-0000-00000000e001','Priya Nair','priya.nair@tatasteel.com','+91 98765 43211','AR Lead','accounts',false),
 ('00000000-0000-0000-0000-00000000e001','Amit Kumar','amit.kumar@tatasteel.com','+91 98765 43212','Logistics Head','logistics',false);

-- directors
insert into public.vendor_directors (vendor_id, full_name, din, designation, source) values
 ('00000000-0000-0000-0000-00000000e001','T.V. Narendran','03083605','Managing Director & CEO','mca'),
 ('00000000-0000-0000-0000-00000000e001','Koushik Chatterjee','00004989','Executive Director & CFO','mca');

-- banking
insert into public.vendor_bank_accounts (vendor_id, scope, account_holder_name, account_number, account_type, currency, bank_name, branch, ifsc, is_primary) values
 ('00000000-0000-0000-0000-00000000e001','domestic','Tata Steel Limited','00078350000061','Current Account','INR','State Bank of India','Fort, Mumbai','SBIN0000300',true),
 ('00000000-0000-0000-0000-00000000e001','domestic','Tata Steel Limited','00012345678901','Current Account','INR','HDFC Bank','Nariman Point, Mumbai','HDFC0002345',false);

-- qualification + esg + infosec
insert into public.vendor_qualification (vendor_id, turnover_y1, turnover_y1_label, turnover_y2, turnover_y2_label,
  turnover_y3, turnover_y3_label, net_worth, profitability_status, auditor, fy_ends_in, years_experience,
  employee_count, manufacturing_capacity, quality_system, iso27001, soc2, data_encryption, incident_response,
  bcp_dr, environmental_policy, sustainability_certs, diversity_status) values
 ('00000000-0000-0000-0000-00000000e001',243832,'FY2022-23',225670,'FY2023-24',258900,'FY2024-25',750000,
  'Profitable','Price Waterhouse Chartered Accountants LLP','March',117,35000,'35 MTPA','TQM',
  true,false,true,true,true,true, array['GRI Standards','CDP Climate'], array['Large Enterprise']);

-- references
insert into public.vendor_references (vendor_id, company_name, contact_name, contact_email, project_description, value_range) values
 ('00000000-0000-0000-0000-00000000e001','Maruti Suzuki India Ltd','Vikram Singh','vikram.singh@maruti.co.in','Automotive-grade steel supply for body panels','₹500Cr+');

-- documents (verified) — Tata Steel
insert into public.vendor_documents (id, vendor_id, doc_type, requirement_key, label, status, file_name, issuer, expires_at, cert_number, verified_at) values
 ('00000000-0000-0000-0000-0000000d0001','00000000-0000-0000-0000-00000000e001','pan_card','pan','PAN Card','verified','pan.pdf',null,null,null, now()-interval '58 days'),
 ('00000000-0000-0000-0000-0000000d0002','00000000-0000-0000-0000-00000000e001','gst_certificate','gst','GST Certificate – Maharashtra','verified','gst_mh.pdf',null,null,null, now()-interval '58 days'),
 ('00000000-0000-0000-0000-0000000d0003','00000000-0000-0000-0000-00000000e001','incorporation_certificate','coi','Certificate of Incorporation','verified','coi.pdf',null,null,null, now()-interval '58 days'),
 ('00000000-0000-0000-0000-0000000d0004','00000000-0000-0000-0000-00000000e001','insurance','insurance','Insurance Certificate','verified','insurance.pdf',null, (current_date+interval '120 days')::date,null, now()-interval '58 days'),
 ('00000000-0000-0000-0000-0000000d0005','00000000-0000-0000-0000-00000000e001','bank_proof','bank_proof','Bank Verification Letter','verified','bank_letter.pdf',null,null,null, now()-interval '58 days'),
 ('00000000-0000-0000-0000-0000000d0006','00000000-0000-0000-0000-00000000e001','iso_9001','iso_9001','ISO 9001 Quality Certificate','verified','iso9001.pdf','Bureau Veritas','2027-06-30','BV-QMS-2024-IN-7892', now()-interval '58 days'),
 ('00000000-0000-0000-0000-0000000d0007','00000000-0000-0000-0000-00000000e001','iso_14001','iso_14001','ISO 14001 Environmental Certificate','verified','iso14001.pdf','TÜV SÜD','2026-12-31','TUV-EMS-2023-IN-4410', now()-interval '58 days')
on conflict (id) do nothing;

-- certifications
insert into public.vendor_certifications (vendor_id, cert_type, issuer, valid_until, cert_number, document_id) values
 ('00000000-0000-0000-0000-00000000e001','ISO 9001 (Quality)','Bureau Veritas','2027-06-30','BV-QMS-2024-IN-7892','00000000-0000-0000-0000-0000000d0006'),
 ('00000000-0000-0000-0000-00000000e001','ISO 14001 (Environment)','TÜV SÜD','2026-12-31','TUV-EMS-2023-IN-4410','00000000-0000-0000-0000-0000000d0007');

-- scorecard (composite 79, medium) + lines
insert into public.vendor_scorecards (id, vendor_id, name, status, scope, composite_score, risk_level, evaluator_name) values
 ('00000000-0000-0000-0000-00000000c001','00000000-0000-0000-0000-00000000e001','FY25 Annual Evaluation','complete',
  array['financial_health','compliance_standing','operational_capability','esg_sustainability']::scorecard_dimension[],
  79,'medium','Harsha Kadimisetty')
on conflict (id) do nothing;
insert into public.vendor_scorecard_lines (scorecard_id, dimension, dimension_weight, criterion, score, data_source, basis) values
 ('00000000-0000-0000-0000-00000000c001','financial_health',0.20,'Revenue Stability',5,'Financial Statements','3y revenue trend stable'),
 ('00000000-0000-0000-0000-00000000c001','financial_health',0.20,'Profitability Trend',4,'Annual Report','Profitable, margins healthy'),
 ('00000000-0000-0000-0000-00000000c001','financial_health',0.20,'Credit Rating',4,'CRISIL','AA/Stable'),
 ('00000000-0000-0000-0000-00000000c001','compliance_standing',0.20,'GST Filing Timeliness',4,'GST Portal','>95% on-time'),
 ('00000000-0000-0000-0000-00000000c001','compliance_standing',0.20,'Sanctions / Debarment Check',5,'Sanctions Screening API','Clean'),
 ('00000000-0000-0000-0000-00000000c001','compliance_standing',0.20,'Anti-Bribery & Corruption',4,'Vendor Declaration','Policy in place'),
 ('00000000-0000-0000-0000-00000000c001','operational_capability',0.20,'On-Time Delivery Rate',4,'PO/GRN Records','96.2% OTD'),
 ('00000000-0000-0000-0000-00000000c001','operational_capability',0.20,'Quality Rejection Rate',4,'QC/Inspection Logs','<1% rejects'),
 ('00000000-0000-0000-0000-00000000c001','esg_sustainability',0.15,'Environmental Policy',3,'ESG Disclosure','GRI + CDP, improving');

-- web insights cache
insert into public.vendor_web_insights (vendor_id, overview, headquarters, founded, employees, revenue, industry,
  stock_ticker, website, market_cap, credit_rating, credit_agency, dnb_rating, key_ratios, key_personnel,
  sanctions_status, pep_status, ratings, refreshed_at) values
 ('00000000-0000-0000-0000-00000000e001',
  'Tata Steel Limited is one of the world''s most geographically diversified steel producers, with operations in over 50 countries and a flagship of the Tata Group.',
  'Mumbai, Maharashtra, India','1907','~80,000','₹2,00,000+ Cr','Metals & Mining — Steel','NSE: TATASTEEL','tatasteel.com',
  '₹1,92,000 Cr','CRISIL AA/Stable','CRISIL','5A1 (Highest)',
  '{"debt_equity":0.68,"current_ratio":1.12,"ebitda_margin":"18.4%","roe":"12.6%","interest_coverage":"5.8x"}'::jsonb,
  '[{"name":"T.V. Narendran","title":"CEO & MD"},{"name":"Koushik Chatterjee","title":"ED & CFO"},{"name":"Noel Tata","title":"Chairman"}]'::jsonb,
  'Clean','Clean',
  '{"google":{"rating":4.1,"reviews":1240},"glassdoor":{"rating":4.0,"reviews":8500}}'::jsonb, now()-interval '2 hours');

insert into public.vendor_news_items (vendor_id, title, source, published_at, sentiment) values
 ('00000000-0000-0000-0000-00000000e001','Tata Steel''s Kalinganagar expansion on track for H2 FY25 commissioning','Economic Times', current_date-30,'positive'),
 ('00000000-0000-0000-0000-00000000e001','Tata Steel reports 3% decline in Q3 revenue amid global steel price softness','Business Standard', current_date-45,'negative'),
 ('00000000-0000-0000-0000-00000000e001','Tata Steel partners with startup for green hydrogen-based steelmaking pilot','Mint', current_date-60,'positive'),
 ('00000000-0000-0000-0000-00000000e001','UK operations restructuring progresses; Port Talbot transition plan shared','Reuters', current_date-75,'neutral');

-- risk screenings (clean)
insert into public.vendor_risk_screenings (vendor_id, screening_type, status, entities_checked, hits, provider, mode, checked_at, result) values
 ('00000000-0000-0000-0000-00000000e001','sanctions','clean',4,0,'OpenSanctions','mock', now()-interval '2 hours','{"lists":["OFAC","EU","UN"]}'::jsonb),
 ('00000000-0000-0000-0000-00000000e001','pep','clean',6,0,'OpenSanctions','mock', now()-interval '2 hours','{}'::jsonb);

-- purchase orders (powers Business Overview)
insert into public.purchase_orders (vendor_id, org_id, po_number, title, category, amount, status, order_date, delivery_date) values
 ('00000000-0000-0000-0000-00000000e001','00000000-0000-0000-0000-0000000000a1','PO-2025-0125','Rebars 12mm — Construction Site Alpha','Rebars & Wire Rods',9500000,'delivered','2025-01-15','2025-02-01'),
 ('00000000-0000-0000-0000-00000000e001','00000000-0000-0000-0000-0000000000a1','PO-2025-0118','HR Coils — Emergency Replenishment','Hot Rolled Coils',41000000,'delivered','2025-01-05','2025-01-20'),
 ('00000000-0000-0000-0000-00000000e001','00000000-0000-0000-0000-0000000000a1','PO-2025-0112','Cold Rolled Sheets — Plant 2','Cold Rolled Sheets',18500000,'invoiced','2024-12-20','2025-01-10'),
 ('00000000-0000-0000-0000-00000000e001','00000000-0000-0000-0000-0000000000a1','PO-2025-0101','Galvanized Steel — Coastal Project','Galvanized Steel',7600000,'paid','2024-12-01','2024-12-18');

-- status history + audit (abridged trail)
insert into public.vendor_status_history (vendor_id, from_status, to_status, reason, at) values
 ('00000000-0000-0000-0000-00000000e001','submitted','under_review','review started', now()-interval '65 days'),
 ('00000000-0000-0000-0000-00000000e001','under_review','approved','due diligence passed', now()-interval '60 days'),
 ('00000000-0000-0000-0000-00000000e001','approved','active','activated', now()-interval '60 days');
insert into public.vendor_audit_log (vendor_id, action, payload, at) values
 ('00000000-0000-0000-0000-00000000e001','status_change','{"to":"approved"}'::jsonb, now()-interval '60 days'),
 ('00000000-0000-0000-0000-00000000e001','document_verified','{"doc":"iso_9001"}'::jsonb, now()-interval '58 days'),
 ('00000000-0000-0000-0000-00000000e001','screening_complete','{"sanctions":"clean"}'::jsonb, now()-interval '2 hours');

-- =============================================================================
-- VENDOR 2 — BHARAT FORGE — INVITED (drives the live demo onboarding)
--   Invitation token is fixed so the demo link is predictable.
-- =============================================================================
insert into public.vendors (id, org_id, slug, legal_name, primary_category, lifecycle_status, tier, risk_level, source) values
 ('00000000-0000-0000-0000-00000000e002','00000000-0000-0000-0000-0000000000a1','bharat-forge','Bharat Forge Limited','Capital & Equipment','invited','unclassified','unrated','manual')
on conflict (id) do nothing;
insert into public.vendor_contacts (vendor_id, full_name, email, phone, designation, role, is_primary) values
 ('00000000-0000-0000-0000-00000000e002','Rakesh Kumar','rakesh@tatasteel-demo.com','+91 98765 12345','Procurement Head','procurement',true);
insert into public.vendor_invitations (org_id, vendor_id, company_name, category, contact_name, email, token, status, source) values
 ('00000000-0000-0000-0000-0000000000a1','00000000-0000-0000-0000-00000000e002','Bharat Forge Limited','Capital & Equipment','Rakesh Kumar','rakesh@tatasteel-demo.com','demo-bharatforge-token','pending','manual')
on conflict (token) do nothing;

-- =============================================================================
-- VENDOR 3 — ASIAN PAINTS — ACTIVE with a doc EXPIRING IN 7 DAYS (alert demo)
-- =============================================================================
insert into public.vendors (id, org_id, slug, legal_name, trade_name, vendor_code, pan, primary_category,
  city, state, lifecycle_status, tier, risk_level, source, composite_score, total_spend, po_count, approved_at) values
 ('00000000-0000-0000-0000-00000000e003','00000000-0000-0000-0000-0000000000a1','asian-paints','Asian Paints Limited','Asian Paints','ASNPT-001','AAACA6666N','Raw Materials',
  'Mumbai','Maharashtra','active','preferred','low','manual',84, 128000000, 56, now()-interval '120 days')
on conflict (id) do nothing;
insert into public.vendor_documents (vendor_id, doc_type, requirement_key, label, status, file_name, issuer, expires_at, cert_number) values
 ('00000000-0000-0000-0000-00000000e003','iso_9001','iso_9001','ISO 9001 Quality Certificate','uploaded','iso9001_ap.pdf','DNV',(current_date + 7),'DNV-QMS-2022-IN-5510'),
 ('00000000-0000-0000-0000-00000000e003','pan_card','pan','PAN Card','verified','pan_ap.pdf',null,null,null);

-- =============================================================================
-- VENDORS 4–10 — span remaining statuses (lighter rows for list/KPI realism)
-- =============================================================================
insert into public.vendors (org_id, slug, legal_name, vendor_code, primary_category, city, state,
  lifecycle_status, tier, risk_level, source, composite_score, total_spend, po_count, registration_progress) values
 ('00000000-0000-0000-0000-0000000000a1','lt-construction','Larsen & Toubro Construction','LTCON-001','Professional Services','Chennai','Tamil Nadu','active','strategic','low','manual',88, 980000000, 210, 100),
 ('00000000-0000-0000-0000-0000000000a1','hindalco','Hindalco Industries Limited','HNDLC-001','Raw Materials','Mumbai','Maharashtra','approved','preferred','medium','manual',72, 0,0,100),
 ('00000000-0000-0000-0000-0000000000a1','siemens-india','Siemens Limited India',null,'Software & Technology','Mumbai','Maharashtra','under_review','conditional','medium','rfx_event',null,0,0,100),
 ('00000000-0000-0000-0000-0000000000a1','cummins-india','Cummins India Limited',null,'Capital & Equipment','Pune','Maharashtra','submitted','unclassified','unrated','rfx_event',null,0,0,100),
 ('00000000-0000-0000-0000-0000000000a1','mahindra-logistics','Mahindra Logistics Limited',null,'Logistics & Freight','Mumbai','Maharashtra','registering','unclassified','unrated','self_registration',null,0,0,45),
 ('00000000-0000-0000-0000-0000000000a1','ultratech-cement','UltraTech Cement Limited','ULTRA-001','Raw Materials','Mumbai','Maharashtra','blocked','approved','high','manual',58, 64000000, 22,100),
 ('00000000-0000-0000-0000-0000000000a1','bharat-electronics','Bharat Electronics Limited',null,'Software & Technology','Bangalore','Karnataka','rejected','unclassified','high','rfx_event',null,0,0,100);

-- a couple POs for L&T so a second vendor has Business-Overview data
insert into public.purchase_orders (vendor_id, org_id, po_number, title, category, amount, status, order_date)
select v.id, v.org_id, 'PO-2025-0207','Civil works — Mundra Phase 2','Construction',125000000,'acknowledged','2025-02-07'
from public.vendors v where v.slug='lt-construction';

-- scorecards for 5 vendors total (Tata already has one) -> add 4 quick ones
insert into public.vendor_scorecards (vendor_id, name, status, composite_score, risk_level, evaluator_name)
select id, 'FY25 Evaluation','complete', s.score, s.risk, 'Harsha Kadimisetty'
from (values
 ('asian-paints',84,'low'::risk_level),
 ('lt-construction',88,'low'::risk_level),
 ('hindalco',72,'medium'::risk_level),
 ('ultratech-cement',58,'high'::risk_level)
) as s(slug, score, risk)
join public.vendors v on v.slug = s.slug;

-- =============================================================================
-- PROSPECTS (match the live Prospects tab screenshot) — early-stage rows
-- =============================================================================
insert into public.vendors (org_id, slug, legal_name, primary_category, lifecycle_status, source, source_ref) values
 ('00000000-0000-0000-0000-0000000000a1','rajesh-fabricators','Rajesh Fabricators Pvt Ltd','Raw Materials','prospect','manual',null),
 ('00000000-0000-0000-0000-0000000000a1','techvista-solutions','TechVista Solutions Inc','IT Services','prospect','rfx_event','RFQ-2025-001'),
 ('00000000-0000-0000-0000-0000000000a1','greenpack-industries','GreenPack Industries','Packaging','registering','self_registration',null),
 ('00000000-0000-0000-0000-0000000000a1','muller-precision','Müller Precision GmbH','Precision Engineering','prospect','manual',null),
 ('00000000-0000-0000-0000-0000000000a1','apex-chemical','Apex Chemical Corp','Chemicals','approved','rfx_event','RFQ-2025-014'),
 ('00000000-0000-0000-0000-0000000000a1','oceanic-logistics','Oceanic Logistics Ltd','Logistics','inactive','manual',null);
insert into public.vendor_contacts (vendor_id, full_name, email, role, is_primary)
select v.id, c.nm, c.em, 'procurement', true from (values
 ('rajesh-fabricators','Rajesh Kumar','rajesh@fabricators.co.in'),
 ('techvista-solutions','Ananya Gupta','ananya@techvista.com'),
 ('greenpack-industries','Suresh Menon','suresh@greenpack.in'),
 ('muller-precision','Hans Müller','hans@muller-precision.de'),
 ('apex-chemical','Vivek Sharma','vivek@apexchem.in'),
 ('oceanic-logistics','Priya Nair','priya@oceanic-log.com')
) as c(slug,nm,em) join public.vendors v on v.slug=c.slug;

-- =============================================================================
-- DEMO USERS — create these AUTH accounts (Supabase Auth) then run link_demo_users()
-- Buyer (Adani tenant):
--   priya@adani-demo.com    buyer_admin
--   arjun@adani-demo.com    buyer_approver
--   neha@adani-demo.com     buyer_requester
-- Vendor:
--   rakesh@tatasteel-demo.com    -> Bharat Forge (e002)  [live demo]
--   meera@tatasteel-demo.com     -> Tata Steel  (e001)
--   (passwords: set in Supabase; e.g. Demo@12345)
-- =============================================================================
create or replace function public.link_demo_users() returns void
language plpgsql security definer set search_path = public as $$
declare adani uuid := '00000000-0000-0000-0000-0000000000a1';
        uid uuid;
begin
  -- BUYERS: map auth.users by email -> org_users + roles
  -- [ASSUMPTION] org_users(user_id,org_id); roles/user_roles(user_id, role). Adapt names if different.
  for uid in select id from auth.users where email in ('priya@adani-demo.com','arjun@adani-demo.com','neha@adani-demo.com') loop
    insert into public.org_users(user_id, org_id) values (uid, adani) on conflict do nothing;
  end loop;
  -- roles (adapt table name to your existing roles schema)
  -- insert into public.user_roles(user_id, role) select id, 'buyer_admin'    from auth.users where email='priya@adani-demo.com' on conflict do nothing;
  -- insert into public.user_roles(user_id, role) select id, 'buyer_approver' from auth.users where email='arjun@adani-demo.com' on conflict do nothing;
  -- insert into public.user_roles(user_id, role) select id, 'buyer_requester'from auth.users where email='neha@adani-demo.com'  on conflict do nothing;

  -- VENDOR USERS + memberships
  insert into public.vendor_users(auth_user_id, email, full_name)
    select id, email, 'Rakesh Kumar' from auth.users where email='rakesh@tatasteel-demo.com'
    on conflict (email) do update set auth_user_id = excluded.auth_user_id;
  insert into public.vendor_users(auth_user_id, email, full_name)
    select id, email, 'Meera Iyer' from auth.users where email='meera@tatasteel-demo.com'
    on conflict (email) do update set auth_user_id = excluded.auth_user_id;

  insert into public.vendor_memberships(vendor_user_id, vendor_id, member_role, is_primary)
    select vu.id, '00000000-0000-0000-0000-00000000e002', 'owner', true
    from public.vendor_users vu where vu.email='rakesh@tatasteel-demo.com' on conflict do nothing;
  insert into public.vendor_memberships(vendor_user_id, vendor_id, member_role, is_primary)
    select vu.id, '00000000-0000-0000-0000-00000000e001', 'owner', true
    from public.vendor_users vu where vu.email='meera@tatasteel-demo.com' on conflict do nothing;
end $$;

-- After creating the 5 auth accounts, run:  select public.link_demo_users();
