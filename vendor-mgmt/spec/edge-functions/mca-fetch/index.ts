// mca-fetch — "Auto-Fetch from MCA": resolve company legal data + directors from a
// PAN or CIN. Live adapter (MCA/Probe42) when MCA_API_KEY + RISK_MODE=live; else an
// AI-synthesised best-effort from public knowledge (demo-safe). Returns for the
// client to write into the Company Profile step.
// POST { pan?, cin?, legal_name? }
import { preflight, json } from "../_shared/cors.ts";
import { callAIJSON } from "../_shared/ai.ts";

Deno.serve(async (req) => {
  const pf = preflight(req); if (pf) return pf;
  try {
    const { pan, cin, legal_name } = await req.json();
    if (!pan && !cin && !legal_name) return json({ ok: false, error: "pan, cin or legal_name required" }, 400);

    const mode = Deno.env.get("RISK_MODE") || "mock";
    const mcaKey = Deno.env.get("MCA_API_KEY");

    if (mode === "live" && mcaKey && cin) {
      // Example Probe42/MCA adapter (endpoint/headers vary by vendor) — fall through to AI on error.
      try {
        const res = await fetch(`https://api.probe42.in/probe_pro/companies/${cin}`, {
          headers: { "x-api-key": mcaKey, "x-api-version": "1.3" },
        });
        if (res.ok) {
          const j = await res.json();
          return json({ ok: true, source: "mca", data: normalizeMca(j) });
        }
      } catch (e) { console.error("mca live failed", e); }
    }

    // AI fallback (demo-safe)
    const { data, degraded } = await callAIJSON<Record<string, unknown>>({
      system: "You return Indian MCA-style company master data as JSON. Use well-known public facts. If unknown, null. Never fabricate director DINs you are unsure of.",
      prompt: `Return JSON { legal_name, entity_type, cin, incorporation_date(YYYY-MM-DD), registered_address, directors:[{full_name,din,designation}] } for company with PAN ${pan ?? "?"}, CIN ${cin ?? "?"}, name ${legal_name ?? "?"}.`,
      json: true,
    });
    if (degraded || !data) return json({ ok: false, degraded: true });
    return json({ ok: true, source: "ai", data });
  } catch (e) {
    return json({ ok: false, error: String(e) }, 500);
  }
});

function normalizeMca(j: Record<string, any>) {
  const c = j.data ?? j;
  return {
    legal_name: c.legal_name ?? c.company_name ?? null,
    entity_type: c.company_category ?? c.company_type ?? null,
    cin: c.cin ?? null,
    incorporation_date: c.incorporation_date ?? null,
    registered_address: c.registered_address ?? null,
    directors: (c.directors ?? c.signatories ?? []).map((d: Record<string, any>) => ({
      full_name: d.name ?? d.full_name, din: d.din, designation: d.designation,
    })),
  };
}
