# 9. ERP / Ariba / SAP / MDG integration layer

> Derived directly from the Adani meetings: integration must be **front-end
> configurable** ("like setting up Salesforce — pick the system, enter credentials,
> test & save, map fields, test payload, no back-end dev"), support **SAP S/4HANA,
> SAP MDG, SAP Ariba, Coupa, Oracle, Baan/Infor**, and do **bi-directional vendor-master
> sync** — pull the buyer's existing vendor master in, and **push AirChain-onboarded
> vendors back into SAP/Ariba**. Plus pull **GRN** data for objective performance.

## 9.1 What integrates (vendor-management scope)

| Flow | Direction | Source/Target | Purpose |
|------|-----------|---------------|---------|
| Vendor master import | inbound (pull) | SAP `API_BUSINESS_PARTNER` (OData) / Ariba Supplier Data API / MDG | Populate AirChain with the buyer's existing suppliers; dedup. |
| Vendor master write-back | outbound (push) | SAP MDG change request / `BAPI_VENDOR_CREATE` (IDoc `CREMAS`) / Ariba Supplier | On approval/activation, create/update the vendor (LIFNR/SMVendorID) in the ERP; store external id. |
| GRN / performance | inbound (pull) | SAP GRN/quality (OData/CDS) | Objective scorecard inputs: on-time delivery %, quality rejection %. |
| PR → sourcing → award write-back | (out of vendor-mgmt scope; noted) | Ariba/SAP workflow API | Tail-spend autonomous-sourcing loop (separate module). |

> `[A7]` Connectors call ERP APIs via HTTPS (OData/REST/SOAP/cXML) reached through the
> customer's SAP Gateway / BTP / Ariba APIs or an agreed middleware. Where only IDoc/RFC
> is available, an agreed file/middleware bridge is assumed. Demo runs in **mock mode**.

## 9.2 Front-end configurable connection (the "Salesforce-style" setup)

Screen `/settings/integrations` (buyer_admin). Steps, all UI, **no backend dev**:
1. **Choose system** — `sap_s4hana | sap_mdg | sap_ariba | coupa | oracle | baan_infor | generic_rest`.
2. **Connection details** — name, base URL/host, environment (sandbox/prod), auth type
   (`api_key | oauth2 | basic | cert`) + credentials.
3. **Test connection** → edge fn `erp-sync` action `test` pings a health/metadata endpoint → green/red.
4. **Save** → row in `integration_connections`; **credentials go to Supabase Vault**, DB stores only `vault_secret_id`.
5. **Field mapping** — map AirChain vendor fields ↔ ERP fields per entity (table `integration_field_mappings`), with optional transform; **payload test** shows the exact request/response for one sample record.
6. **Schedule** — manual / on-event (on approval) / periodic (pg_cron) for reconciliation.

Default SAP vendor-master field map (editable in UI):
| AirChain | SAP (BP/LFA1) | Ariba |
|----------|---------------|-------|
| `legal_name` | `BusinessPartnerName` / `NAME1` | `SMVendorName` |
| `vendor_code` | `Supplier` / `LIFNR` | `SMVendorID` |
| `pan` | `TaxNumber3` / `STCD3` | custom field |
| `cin` | `TaxNumber` | custom field |
| GSTIN (per reg) | `TaxNumber1`/region | custom field |
| `addr_*` | `Address` node | address block |
| bank (IFSC/acct) | `SupplierBank`/`LFBK` | remittance |
| `vendor_class` (OEM/dealer) | MDG `preferred`/partner role + Z-field | classification |

## 9.3 Data model (in `migrations/0007_integration_dd_tagging.sql`)

- `integration_connections` — system_type, name, base_url, environment, auth_type, vault_secret_id, status, last_test_at, created_by, org_id.
- `integration_field_mappings` — connection_id, entity (`vendor`|`grn`), source_field, target_field, transform, direction.
- `vendor_external_refs` — vendor_id, connection_id, external_system, external_id (LIFNR/SMVendorID), last_synced_at, sync_status, sync_hash. (1 vendor ↔ many ERP systems.)
- `integration_sync_runs` — connection_id, direction (`inbound`|`outbound`), entity, status (`running|success|partial|error`), total/ok/failed counts, started_at, finished_at, error, triggered_by.
- `integration_sync_records` — run_id, vendor_id?, external_id?, action (`create|update|skip|conflict`), status, payload jsonb, error.
- `vendor_grn_metrics` — vendor_id, period, on_time_delivery_pct, quality_rejection_pct, grn_count, source_connection_id. (feeds scorecard objective lines.)

All with `created_at/updated_at/created_by`, RLS = buyer org / `buyer_admin`, in 0007.

## 9.4 `erp-sync` edge function (one function, per-system adapters)

`POST { action, connection_id, entity?, vendor_id?, mode? }`
- `action: "test"` — connectivity/metadata check → `{ ok, info }`.
- `action: "pull"` `entity:"vendor"` — fetch external vendor master (paged) → upsert into `vendors` + `vendor_external_refs`, run dedup (`vendor-dedupe`), write a sync run.
- `action: "push"` `vendor_id` — map vendor → ERP payload → create/update (SAP MDG CR or BP create / Ariba supplier) → store `external_id`; called automatically on `→ active` transition.
- `action: "pull"` `entity:"grn"` — fetch GRN metrics → `vendor_grn_metrics` → feed scorecard.
- **Adapters**: `sap.ts`, `ariba.ts`, `coupa.ts`, `oracle.ts`, `generic.ts`; selected by `connection.system_type`. Credentials read from **Vault** via `vault_secret_id`. **Mock mode** (`INTEGRATION_MODE=mock`, default) returns deterministic sample vendor master + GRN so the demo shows the loop with zero ERP dependency.
- Every run → `integration_sync_runs` + `integration_sync_records` + `vendor_audit_log` (`erp_sync`). Realtime on `integration_sync_runs` powers a live progress UI.

## 9.5 Push-on-approval (closing the loop)

When `vendor_transition(..., 'active')` fires, the client (or a DB `pg_net` hook) calls
`erp-sync action:"push"` for every configured `integration_connections` of the org →
the approved vendor is created in SAP vendor master / Ariba, `vendor_external_refs`
records the `external_id`, and the 360 shows **"Synced to SAP (LIFNR 0001234567)"**.
This is the concrete answer to Adani's "for every customer we update your existing master."

## 9.6 Security & ops
- Credentials in **Supabase Vault** (never plaintext columns); functions use service role.
- Per-connection rate limiting + retry/backoff; partial-success runs are resumable.
- All syncs audited; RLS limits integration config to `buyer_admin` in the org.
- BYOC / data-residency posture inherited from Supabase project region (see `11-ENTERPRISE-ARCHITECTURE.md`).
