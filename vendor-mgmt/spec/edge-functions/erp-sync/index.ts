// erp-sync — front-end-configured connector to SAP S/4HANA, SAP MDG, Ariba, Coupa,
// Oracle, Baan/Infor. Bi-directional vendor-master sync + GRN pull. MOCK by default
// so the demo runs with zero ERP dependency; live adapters call the customer's APIs
// with credentials read from Supabase Vault.
//
// POST { action:"test"|"pull"|"push"|"grn", connection_id, vendor_id?, entity?, mode? }
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { preflight, json } from "../_shared/cors.ts";

Deno.serve(async (req) => {
  const pf = preflight(req); if (pf) return pf;
  try {
    const { action, connection_id, vendor_id, entity } = await req.json();
    const supa = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
    const mode = (await req.json().catch(() => ({}))).mode ?? (Deno.env.get("INTEGRATION_MODE") || "mock");

    const { data: conn } = await supa.from("integration_connections").select("*").eq("id", connection_id).single();
    if (!conn) return json({ ok: false, error: "connection not found" }, 404);

    // creds (live only): read from Vault by conn.vault_secret_id (omitted in mock)
    // const creds = await readVault(supa, conn.vault_secret_id);

    if (action === "test") {
      const info = mode === "mock"
        ? { reachable: true, system: conn.system_type, sample_entities: ["BusinessPartner", "GRN"] }
        : await liveTest(conn);
      await supa.from("integration_connections").update({
        status: info.reachable ? "connected" : "error", last_test_at: new Date().toISOString(), last_test_info: info,
      }).eq("id", connection_id);
      return json({ ok: info.reachable, info });
    }

    if (action === "pull" && (entity ?? "vendor") === "vendor") {
      const run = await startRun(supa, conn, "inbound", "vendor");
      const rows = mode === "mock" ? mockVendorMaster(conn.system_type) : await livePullVendors(conn);
      let ok = 0, failed = 0;
      for (const r of rows) {
        try {
          // upsert by external_id; create a lightweight prospect if new
          const { data: ex } = await supa.from("vendor_external_refs")
            .select("vendor_id").eq("external_system", conn.system_type).eq("external_id", r.external_id).maybeSingle();
          let vId = ex?.vendor_id as string | undefined;
          if (!vId) {
            const slug = r.legal_name.toLowerCase().replace(/[^a-z0-9]+/g, "-").slice(0, 40) + "-" + r.external_id.slice(-4);
            const ins = await supa.from("vendors").insert({
              org_id: conn.org_id, slug, legal_name: r.legal_name, pan: r.pan, vendor_code: r.external_id,
              primary_category: r.category, lifecycle_status: "active", source: "manual", vendor_class: r.vendor_class ?? "other",
            }).select("id").single();
            vId = ins.data?.id;
          }
          await supa.from("vendor_external_refs").upsert({
            vendor_id: vId, connection_id, external_system: conn.system_type, external_id: r.external_id,
            last_synced_at: new Date().toISOString(), sync_status: "ok", sync_hash: r.hash,
          }, { onConflict: "vendor_id,external_system" });
          await logRec(supa, run.id, vId, r.external_id, ex ? "update" : "create", "ok", r);
          ok++;
        } catch (e) { await logRec(supa, run.id, null, r.external_id, "create", "error", r, String(e)); failed++; }
      }
      await finishRun(supa, run.id, rows.length, ok, failed);
      return json({ ok: true, run_id: run.id, pulled: rows.length, ok, failed });
    }

    if (action === "push") {
      const run = await startRun(supa, conn, "outbound", "vendor");
      const { data: v } = await supa.from("vendors").select("*").eq("id", vendor_id).single();
      const payload = mapVendorToErp(conn.system_type, v);
      const res = mode === "mock"
        ? { external_id: "00010" + String(Math.floor(Math.random() * 90000)) }   // mock LIFNR
        : await livePushVendor(conn, payload);
      await supa.from("vendor_external_refs").upsert({
        vendor_id, connection_id, external_system: conn.system_type, external_id: res.external_id,
        last_synced_at: new Date().toISOString(), sync_status: "ok",
      }, { onConflict: "vendor_id,external_system" });
      await logRec(supa, run.id, vendor_id, res.external_id, "create", "ok", payload);
      await finishRun(supa, run.id, 1, 1, 0);
      await supa.from("vendor_audit_log").insert({ vendor_id, action: "erp_sync",
        payload: { direction: "outbound", system: conn.system_type, external_id: res.external_id } });
      return json({ ok: true, external_id: res.external_id });
    }

    if (action === "grn") {
      const metrics = mode === "mock"
        ? { period: "FY2024-25", on_time_delivery_pct: 96.2, quality_rejection_pct: 0.8, grn_count: 142 }
        : await livePullGrn(conn, vendor_id);
      await supa.from("vendor_grn_metrics").insert({ vendor_id, source_connection_id: connection_id, ...metrics });
      return json({ ok: true, metrics });
    }

    return json({ ok: false, error: "unknown action" }, 400);
  } catch (e) {
    return json({ ok: false, error: String(e) }, 500);
  }
});

// ---- run bookkeeping ----
async function startRun(supa: any, conn: any, direction: string, entity: string) {
  const { data } = await supa.from("integration_sync_runs").insert({
    connection_id: conn.id, org_id: conn.org_id, direction, entity, status: "running",
  }).select("*").single();
  return data;
}
async function finishRun(supa: any, runId: string, total: number, ok: number, failed: number) {
  await supa.from("integration_sync_runs").update({
    status: failed === 0 ? "success" : ok === 0 ? "error" : "partial",
    total_count: total, ok_count: ok, failed_count: failed, finished_at: new Date().toISOString(),
  }).eq("id", runId);
}
async function logRec(supa: any, runId: string, vId: string | null, extId: string, action: string, status: string, payload: unknown, error?: string) {
  await supa.from("integration_sync_records").insert({ run_id: runId, vendor_id: vId, external_id: extId, action, status, payload, error });
}

// ---- field mapping (AirChain -> ERP) ----
function mapVendorToErp(system: string, v: any): Record<string, unknown> {
  if (system.startsWith("sap")) {
    return { Supplier: v.vendor_code, BusinessPartnerName: v.legal_name, TaxNumber3: v.pan, TaxNumber: v.cin,
      AddressLine1: v.addr_line1, CityName: v.city, Region: v.state, PostalCode: v.pincode, Country: "IN",
      VendorClass: v.vendor_class, IsPreferred: v.is_preferred };
  }
  return { SMVendorID: v.vendor_code, SMVendorName: v.legal_name, pan: v.pan, classification: v.vendor_class };
}

// ---- MOCK data (deterministic, demo-safe) ----
function mockVendorMaster(system: string) {
  const base = [
    { external_id: "0001000045", legal_name: "SKF India Limited", pan: "AAACS1234F", category: "Capital & Equipment", vendor_class: "oem" },
    { external_id: "0001000046", legal_name: "Schaeffler India Limited", pan: "AAACS5678G", category: "Capital & Equipment", vendor_class: "oem" },
    { external_id: "0001000047", legal_name: "Bearing Distributors Pvt Ltd", pan: "AAACB9012H", category: "Capital & Equipment", vendor_class: "dealer" },
  ];
  return base.map((b) => ({ ...b, hash: `${system}:${b.external_id}` }));
}

// ---- LIVE adapter stubs (implement per customer; fall back / throw to mock) ----
async function liveTest(conn: any) {
  // e.g. GET {base_url}/sap/opu/odata/sap/API_BUSINESS_PARTNER/$metadata  (SAP)
  return { reachable: false, note: "configure live adapter for " + conn.system_type };
}
async function livePullVendors(_conn: any): Promise<any[]> { throw new Error("live adapter not configured"); }
async function livePushVendor(_conn: any, _payload: unknown): Promise<{ external_id: string }> { throw new Error("live adapter not configured"); }
async function livePullGrn(_conn: any, _vendorId: string) { throw new Error("live adapter not configured"); }
