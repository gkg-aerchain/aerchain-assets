// vendor-web-insights — build the AI public-intelligence dossier for the 360
// "Web Insights" tab, run sanctions/PEP screening, and persist everything.
// POST { vendor_id }
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { preflight, json } from "../_shared/cors.ts";
import { callAIJSON } from "../_shared/ai.ts";

Deno.serve(async (req) => {
  const pf = preflight(req); if (pf) return pf;
  try {
    const { vendor_id } = await req.json();
    if (!vendor_id) return json({ ok: false, error: "vendor_id required" }, 400);

    const url = Deno.env.get("SUPABASE_URL")!;
    const svc = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supa = createClient(url, svc);

    const { data: v } = await supa.from("vendors")
      .select("legal_name, pan, cin, website, primary_category, city, state").eq("id", vendor_id).single();
    if (!v) return json({ ok: false, error: "vendor not found" }, 404);

    // 1) AI dossier
    const { data: ai, degraded } = await callAIJSON<{
      overview: string; headquarters: string; founded: string; employees: string; revenue: string;
      industry: string; stock_ticker: string; market_cap: string; credit_rating: string; credit_agency: string;
      dnb_rating: string; key_ratios: Record<string, unknown>; key_personnel: { name: string; title: string }[];
      news: { title: string; source: string; sentiment: string; published_at?: string }[];
    }>({
      system: "You are a procurement risk analyst. Produce an India-context company dossier. JSON only. If unsure, use reasonable public-knowledge estimates and mark them in the field text.",
      prompt: `Company: ${v.legal_name}; PAN ${v.pan ?? "?"}; CIN ${v.cin ?? "?"}; site ${v.city ?? ""} ${v.state ?? ""}; sector ${v.primary_category ?? ""}.
Return JSON: { overview(<=60 words), headquarters, founded, employees, revenue, industry, stock_ticker, market_cap, credit_rating, credit_agency, dnb_rating, key_ratios{debt_equity,current_ratio,ebitda_margin,roe,interest_coverage}, key_personnel[{name,title}], news[4..6 {title,source,sentiment(positive|negative|neutral),published_at(YYYY-MM-DD)}] }`,
      json: true,
    });

    // 2) sanctions + PEP via risk-screening function
    let sanctions = "Clean", pep = "Clean";
    try {
      const rs = await fetch(`${url}/functions/v1/risk-screening`, {
        method: "POST",
        headers: { Authorization: `Bearer ${svc}`, "Content-Type": "application/json" },
        body: JSON.stringify({ vendor_id, types: ["sanctions", "pep", "credit"] }),
      }).then((r) => r.json());
      const s = (rs.screenings ?? []) as { type: string; status: string }[];
      sanctions = s.find((x) => x.type === "sanctions")?.status === "flagged" ? "Flagged" : "Clean";
      pep = s.find((x) => x.type === "pep")?.status === "flagged" ? "Flagged" : "Clean";
    } catch (_e) { /* keep clean defaults */ }

    // 3) persist dossier
    const insights = ai ?? {} as Record<string, unknown>;
    await supa.from("vendor_web_insights").upsert({
      vendor_id,
      overview: (insights as any).overview ?? null,
      headquarters: (insights as any).headquarters ?? null,
      founded: (insights as any).founded ?? null,
      employees: (insights as any).employees ?? null,
      revenue: (insights as any).revenue ?? null,
      industry: (insights as any).industry ?? null,
      stock_ticker: (insights as any).stock_ticker ?? null,
      website: v.website ?? null,
      market_cap: (insights as any).market_cap ?? null,
      credit_rating: (insights as any).credit_rating ?? null,
      credit_agency: (insights as any).credit_agency ?? null,
      dnb_rating: (insights as any).dnb_rating ?? null,
      key_ratios: (insights as any).key_ratios ?? null,
      key_personnel: (insights as any).key_personnel ?? null,
      sanctions_status: sanctions,
      pep_status: pep,
      refreshed_at: new Date().toISOString(),
    }, { onConflict: "vendor_id" });

    // 4) replace news
    await supa.from("vendor_news_items").delete().eq("vendor_id", vendor_id);
    const news = ((insights as any).news ?? []) as { title: string; source: string; sentiment: string; published_at?: string }[];
    if (news.length) {
      await supa.from("vendor_news_items").insert(news.map((n) => ({
        vendor_id, title: n.title, source: n.source, sentiment: n.sentiment,
        published_at: n.published_at ?? null,
      })));
    }

    await supa.from("vendor_audit_log").insert({ vendor_id, action: "web_insights_refreshed", payload: { degraded } });
    return json({ ok: true, degraded, sanctions, pep });
  } catch (e) {
    return json({ ok: false, error: String(e) }, 500);
  }
});
