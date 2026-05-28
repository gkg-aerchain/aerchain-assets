// vendor-dedupe — master-data rationalization helper (Adani's "MDL chaos, multiple
// codes per item/vendor"). Finds likely duplicate vendor records within an org by
// name/PAN similarity (+ optional AI confirmation) and writes review candidates.
// Target: 70-80% out-of-the-box matching, improved by human confirm/dismiss.
// POST { org_id, vendor_id? } -> { ok, candidates:[{vendor_id, match_vendor_id, score, reason}] }
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { preflight, json } from "../_shared/cors.ts";

const norm = (s: string) => (s || "").toLowerCase().replace(/\b(pvt|private|ltd|limited|llp|inc|corp|co|the)\b/g, "").replace(/[^a-z0-9]/g, "");
function trigramSim(a: string, b: string): number {
  const grams = (s: string) => new Set([...Array(Math.max(0, s.length - 2))].map((_, i) => s.slice(i, i + 3)));
  const A = grams(a), B = grams(b); if (!A.size || !B.size) return 0;
  let inter = 0; for (const g of A) if (B.has(g)) inter++;
  return inter / (A.size + B.size - inter);
}

Deno.serve(async (req) => {
  const pf = preflight(req); if (pf) return pf;
  try {
    const { org_id, vendor_id } = await req.json();
    const supa = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
    const { data: vendors } = await supa.from("vendors").select("id, legal_name, pan").eq("org_id", org_id);
    const list = vendors ?? [];
    const candidates: { vendor_id: string; match_vendor_id: string; score: number; reason: string }[] = [];

    const scope = vendor_id ? list.filter((v) => v.id === vendor_id) : list;
    for (const a of scope) {
      for (const b of list) {
        if (a.id >= b.id) continue;
        let score = trigramSim(norm(a.legal_name), norm(b.legal_name));
        let reason = "name similarity";
        if (a.pan && b.pan && a.pan === b.pan) { score = Math.max(score, 0.97); reason = "identical PAN"; }
        if (score >= 0.72) candidates.push({ vendor_id: a.id, match_vendor_id: b.id, score: Number(score.toFixed(2)), reason });
      }
    }

    for (const c of candidates) {
      await supa.from("vendor_duplicate_candidates").upsert({
        vendor_id: c.vendor_id, match_vendor_id: c.match_vendor_id, score: c.score, reason: c.reason, status: "open",
      });
    }
    return json({ ok: true, candidates });
  } catch (e) {
    return json({ ok: false, error: String(e) }, 500);
  }
});
