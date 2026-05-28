// vendor-classify — AI-suggest the vendor tag Adani needs (OEM vs dealer/distributor),
// preferred flag, and brand_tags. Returns a suggestion; the buyer confirms before write
// (and it can then be synced to SAP MDG as the preferred/partner-role tag via erp-sync).
// POST { vendor_id } -> { ok, suggestion:{ vendor_class, is_preferred, brand_tags[], rationale } }
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { preflight, json } from "../_shared/cors.ts";
import { callAIJSON } from "../_shared/ai.ts";

Deno.serve(async (req) => {
  const pf = preflight(req); if (pf) return pf;
  try {
    const { vendor_id } = await req.json();
    const supa = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
    const { data: v } = await supa.from("vendors")
      .select("legal_name, primary_category, business_description, website").eq("id", vendor_id).single();

    const { data, degraded } = await callAIJSON<{ vendor_class: string; is_preferred: boolean; brand_tags: string[]; rationale: string }>({
      system: "You classify B2B suppliers for procurement master data. JSON only.",
      prompt: `Classify ${JSON.stringify(v)}. vendor_class one of oem|dealer|distributor|channel_partner|manufacturer|service_provider|other. ` +
              `Detect brands they represent (e.g. SKF, Schaeffler, NSK) into brand_tags. ` +
              `Set is_preferred true only if clearly a primary/strategic OEM. Return {vendor_class,is_preferred,brand_tags,rationale}.`,
      json: true,
    });
    if (degraded || !data) return json({ ok: false, degraded: true });
    return json({ ok: true, suggestion: data });
  } catch (e) {
    return json({ ok: false, error: String(e) }, 500);
  }
});
