// risk-screening — pluggable third-party risk checks with deterministic MOCK mode.
// POST { vendor_id, types?: string[], mode?: "mock"|"live" }
// Writes one vendor_risk_screenings row per type; returns a summary.
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { preflight, json } from "../_shared/cors.ts";

type Screen = { type: string; status: string; entities_checked: number; hits: number; provider: string; result: unknown };

Deno.serve(async (req) => {
  const pf = preflight(req); if (pf) return pf;
  try {
    const body = await req.json();
    const vendor_id: string = body.vendor_id;
    const types: string[] = body.types ?? ["sanctions", "pep", "credit", "news", "geographic"];
    const mode: string = body.mode ?? (Deno.env.get("RISK_MODE") || "mock");
    if (!vendor_id) return json({ ok: false, error: "vendor_id required" }, 400);

    const supa = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
    const { data: vendor } = await supa.from("vendors").select("legal_name, country, state").eq("id", vendor_id).single();
    const { data: directors } = await supa.from("vendor_directors").select("full_name").eq("vendor_id", vendor_id);
    const names = [vendor?.legal_name, ...(directors ?? []).map((d) => d.full_name)].filter(Boolean) as string[];

    const out: Screen[] = [];
    for (const t of types) {
      out.push(mode === "live" ? await live(t, names, vendor) : mock(t, names, vendor));
    }

    // persist + audit
    for (const s of out) {
      await supa.from("vendor_risk_screenings").insert({
        vendor_id, screening_type: s.type, status: s.status,
        entities_checked: s.entities_checked, hits: s.hits, provider: s.provider,
        mode, checked_at: new Date().toISOString(), result: s.result,
      });
    }
    await supa.from("vendor_audit_log").insert({
      vendor_id, action: "screening_complete",
      payload: { mode, summary: out.map((s) => ({ type: s.type, status: s.status })) },
    });

    const flagged = out.some((s) => s.status === "flagged");
    return json({ ok: true, mode, flagged, screenings: out });
  } catch (e) {
    return json({ ok: false, error: String(e) }, 500);
  }
});

// ---------- MOCK (deterministic, demo-safe) ----------
function mock(type: string, names: string[], vendor: { state?: string; country?: string } | null): Screen {
  switch (type) {
    case "sanctions":
      return { type, status: "clean", entities_checked: names.length, hits: 0, provider: "mock:OpenSanctions",
        result: { lists: ["OFAC", "EU", "UN"], matched: [] } };
    case "pep":
      return { type, status: "clean", entities_checked: Math.max(1, names.length - 1), hits: 0, provider: "mock:OpenSanctions",
        result: { persons_screened: Math.max(1, names.length - 1) } };
    case "credit":
      return { type, status: "clean", entities_checked: 1, hits: 0, provider: "mock:CRISIL/D&B",
        result: { credit_rating: "CRISIL AA/Stable", dnb_rating: "5A1 (Highest)" } };
    case "news":
      return { type, status: "clean", entities_checked: 1, hits: 0, provider: "mock:NewsAPI",
        result: { items: [
          { title: "Company on track with capacity expansion", sentiment: "positive", source: "Economic Times" },
          { title: "Quarterly revenue softens on price pressure", sentiment: "negative", source: "Business Standard" },
        ] } };
    case "geographic":
      return { type, status: "clean", entities_checked: 1, hits: 0, provider: "mock:CountryRiskIndex",
        result: { region: vendor?.state ?? "India", assessment: "Stable economy, low conflict zone" } };
    case "adverse_media":
      return { type, status: "clean", entities_checked: 1, hits: 0, provider: "mock:AI",
        result: { summary: "No material adverse media identified in the last 12 months." } };
    default:
      return { type, status: "clean", entities_checked: 0, hits: 0, provider: "mock", result: {} };
  }
}

// ---------- LIVE (adapters; fall back to mock on error → degraded) ----------
async function live(type: string, names: string[], vendor: { state?: string; country?: string } | null): Promise<Screen> {
  try {
    if (type === "sanctions" || type === "pep") {
      const key = Deno.env.get("OPENSANCTIONS_API_KEY");
      if (!key) throw new Error("no OPENSANCTIONS_API_KEY");
      const queries = Object.fromEntries(names.map((n, i) => [String(i), { schema: "Person", properties: { name: [n] } }]));
      const res = await fetch("https://api.opensanctions.org/match/default", {
        method: "POST",
        headers: { Authorization: `ApiKey ${key}`, "Content-Type": "application/json" },
        body: JSON.stringify({ queries }),
      });
      const j = await res.json();
      const hits = Object.values(j.responses ?? {}).filter((r: unknown) => ((r as { results?: unknown[] }).results?.length ?? 0) > 0).length;
      return { type, status: hits > 0 ? "flagged" : "clean", entities_checked: names.length, hits, provider: "OpenSanctions", result: j };
    }
    // news, credit, geographic live adapters omitted for brevity → mock
    return { ...mock(type, names, vendor), result: { ...(mock(type, names, vendor).result as object), degraded: true } };
  } catch (e) {
    const m = mock(type, names, vendor);
    return { ...m, result: { ...(m.result as object), degraded: true, error: String(e) } };
  }
}
