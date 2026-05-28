// ai-evaluate — suggest scorecard scores (1..5) with data_source + basis for the
// chosen dimensions. Human reviews/edits before saving (ai_suggested=true).
// POST { vendor_id, dimensions: string[] }  -> { ok, lines:[{dimension,criterion,score,data_source,basis}] }
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { preflight, json } from "../_shared/cors.ts";
import { callAIJSON } from "../_shared/ai.ts";

Deno.serve(async (req) => {
  const pf = preflight(req); if (pf) return pf;
  try {
    const { vendor_id, dimensions } = await req.json();
    if (!vendor_id) return json({ ok: false, error: "vendor_id required" }, 400);
    const supa = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);

    // gather signals
    const [{ data: v }, { data: q }, { data: scr }, { data: po }] = await Promise.all([
      supa.from("vendors").select("legal_name, primary_category, total_spend, po_count").eq("id", vendor_id).single(),
      supa.from("vendor_qualification").select("*").eq("vendor_id", vendor_id).maybeSingle(),
      supa.from("vendor_risk_screenings").select("screening_type,status").eq("vendor_id", vendor_id),
      supa.from("purchase_orders").select("status").eq("vendor_id", vendor_id),
    ]);

    const { data, degraded } = await callAIJSON<{ lines: unknown[] }>({
      system: "You are a vendor due-diligence analyst. Score conservatively when evidence is thin. JSON only.",
      prompt: `Vendor: ${JSON.stringify(v)}\nQualification: ${JSON.stringify(q)}\nScreenings: ${JSON.stringify(scr)}\nPOs: ${JSON.stringify(po)}\n
For each requested dimension ${JSON.stringify(dimensions)}, return its standard criteria. Output JSON:
{ "lines": [ { "dimension": "...", "criterion": "...", "score": 1-5, "data_source": "...", "basis": "one line" } ] }`,
      json: true,
    });
    if (degraded || !data) return json({ ok: false, degraded: true });
    return json({ ok: true, lines: data.lines ?? [] });
  } catch (e) {
    return json({ ok: false, error: String(e) }, 500);
  }
});
