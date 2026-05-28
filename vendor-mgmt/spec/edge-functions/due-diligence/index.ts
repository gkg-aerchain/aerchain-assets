// due-diligence — runs the configurable DD checklist for a vendor (the "30-40 checks"
// Adani asked for: OFAC, D&B, Equifax, GST/MSME, PAN, sanctions/PEP, ProcessUnity, plus
// AI checks). Writes vendor_due_diligence_items and returns the approval-gate status.
// Human checks (site/reference) are created as manual_review for a person to complete
// via the recording UI. MOCK by default (<$0.50/vendor, demo-safe).
//
// POST { vendor_id, check_keys?: string[], mode?: "mock"|"live" }
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { preflight, json } from "../_shared/cors.ts";
import { callAIJSON } from "../_shared/ai.ts";

Deno.serve(async (req) => {
  const pf = preflight(req); if (pf) return pf;
  try {
    const { vendor_id, check_keys, mode } = await req.json();
    const m = mode ?? (Deno.env.get("RISK_MODE") || "mock");
    if (!vendor_id) return json({ ok: false, error: "vendor_id required" }, 400);
    const supa = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);

    const { data: vendor } = await supa.from("vendors").select("legal_name, pan, risk_level").eq("id", vendor_id).single();
    const { data: checks } = await supa.from("due_diligence_checks").select("*").eq("enabled", true).order("sort_order");
    const wanted = (checks ?? []).filter((c) => !check_keys || check_keys.includes(c.check_key));

    for (const c of wanted) {
      const r = await runCheck(c, vendor, m);
      await supa.from("vendor_due_diligence_items").upsert({
        vendor_id, check_key: c.check_key, status: r.status, source: c.default_source,
        result: r.result, performed_at: r.status === "manual_review" ? null : new Date().toISOString(),
        note: r.note ?? null,
      }, { onConflict: "vendor_id,check_key" });
    }

    await supa.from("vendor_audit_log").insert({ vendor_id, action: "due_diligence_run",
      payload: { mode: m, checks: wanted.map((c) => c.check_key) } });

    const { data: gate } = await supa.rpc("dd_gate_status", { p_vendor: vendor_id });
    return json({ ok: true, gate, ran: wanted.length });
  } catch (e) {
    return json({ ok: false, error: String(e) }, 500);
  }
});

async function runCheck(c: { check_key: string; default_source: string }, vendor: any, mode: string):
  Promise<{ status: string; result: unknown; note?: string }> {
  // Human checks are never auto-passed — create a task for a person.
  if (c.default_source === "human") {
    return { status: "manual_review", result: { instructions: "Complete via the DD recording UI and attach evidence." } };
  }

  if (mode === "mock") {
    switch (c.check_key) {
      case "pan_verify": return { status: "pass", result: { pan: vendor?.pan, name_match: true } };
      case "gst_active": return { status: "pass", result: { status: "Active", filing_rate: "100%" } };
      case "msme_status": return { status: "pass", result: { msme: "Registered (Udyam)" } };
      case "sanctions_ofac": return { status: "pass", result: { lists: ["OFAC"], hits: 0 } };
      case "sanctions_un_eu": return { status: "pass", result: { lists: ["UN", "EU"], hits: 0 } };
      case "pep_screen": return { status: "pass", result: { hits: 0 } };
      case "debarment_check": return { status: "pass", result: { hits: 0 } };
      case "credit_dnb": return { status: "pass", result: { rating: "5A1 (Highest)", paydex: 78 } };
      case "credit_equifax": return { status: "pass", result: { score: 720, band: "Low risk" } };
      case "processunity_score": return { status: "pass", result: { score: 82, band: "Acceptable" } };
      case "adverse_media":
      case "litigation_scan":
      case "financial_health":
        return { status: "pass", result: { summary: "No material adverse findings (mock)." } };
      default: return { status: "pass", result: {} };
    }
  }

  // LIVE: route to the right provider; AI checks via the gateway, others via adapters.
  if (["adverse_media", "litigation_scan", "financial_health"].includes(c.check_key)) {
    const { data, degraded } = await callAIJSON<{ finding: string; risk: string }>({
      system: "You are a vendor due-diligence analyst. Be factual and conservative. JSON only.",
      prompt: `Check "${c.check_key}" for ${vendor?.legal_name} (PAN ${vendor?.pan}). Return {finding, risk: "none|low|medium|high"}.`,
      json: true,
    });
    if (degraded || !data) return { status: "manual_review", result: { note: "AI unavailable" } };
    return { status: data.risk === "high" ? "fail" : "pass", result: data };
  }
  // sanctions/pep -> reuse risk-screening; credit/gst/pan/processunity -> their APIs (omitted here)
  return { status: "manual_review", result: { note: "configure live adapter for " + c.check_key } };
}
