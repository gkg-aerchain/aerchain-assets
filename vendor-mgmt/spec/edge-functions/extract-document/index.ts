// extract-document — vision OCR a vendor doc, classify it, extract fields, and
// (optionally) file it into its required slot. Returns the extraction for the
// client to map into the onboarding wizard. Provider-agnostic via _shared/ai.ts.
//
// POST { vendor_id, storage_path, mime, file_name?, save?:boolean }
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders, preflight, json } from "../_shared/cors.ts";
import { callAIJSON } from "../_shared/ai.ts";

const SCHEMA = `{
  "doc_type": "one of: pan_card|gst_certificate|incorporation_certificate|iso_9001|iso_14001|iso_27001|insurance|bank_proof|material_test_certificate|msme_certificate|financial_statement|msa|other",
  "requirement_key": "one of: pan|gst|coi|iso_9001|iso_14001|insurance|bank_proof|material_test|msa|null",
  "confidence": 0.0,
  "fields": {
    "legal_name": null, "pan": null, "cin": null, "entity_type": null, "incorporation_date": null,
    "gstin": null, "state": null, "jurisdiction_code": null, "address": null,
    "issuer": null, "cert_number": null, "issue_date": null, "expires_at": null,
    "account_holder": null, "account_number": null, "ifsc": null, "bank_name": null, "branch": null,
    "turnover": null, "net_worth": null, "auditor": null
  }
}`;

Deno.serve(async (req) => {
  const pf = preflight(req); if (pf) return pf;
  try {
    const { vendor_id, storage_path, mime, file_name, save } = await req.json();
    if (!vendor_id || !storage_path) return json({ ok: false, error: "vendor_id and storage_path required" }, 400);

    const supa = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);

    // download the file (service role bypasses RLS) and base64-encode
    const dl = await supa.storage.from("vendor-documents").download(storage_path);
    if (dl.error) return json({ ok: false, error: dl.error.message }, 400);
    const buf = new Uint8Array(await dl.data.arrayBuffer());
    const base64 = btoa(String.fromCharCode(...buf));
    const m = mime || "image/png";

    // PDFs: gpt-4o vision reads image inputs; for PDFs convert first page client-side
    // OR rely on the model's file handling. Here we pass as image for png/jpg.
    const { data, degraded } = await callAIJSON<Record<string, unknown>>({
      system: "You are a precise Indian B2B procurement document parser. Extract identifiers EXACTLY (PAN 10 chars, GSTIN 15 chars, IFSC 11 chars). If a field is absent use null. Never invent values.",
      prompt: `Identify this document and extract fields. Return ONLY JSON exactly matching this schema:\n${SCHEMA}`,
      images: m.startsWith("image/") ? [{ mime: m, base64 }] : undefined,
      json: true,
    });

    if (degraded || !data) return json({ ok: false, degraded: true, error: "extraction unavailable" });

    let document_id: string | null = null;
    if (save) {
      const reqKey = (data.requirement_key as string) || null;
      const ext = (file_name?.split(".").pop() || (m.split("/")[1] ?? "bin"));
      const dest = `${vendor_id}/${reqKey || crypto.randomUUID()}.${ext}`;
      // move from inbox to slot
      await supa.storage.from("vendor-documents").move(storage_path, dest).catch(() => {});
      const ins = await supa.from("vendor_documents").insert({
        vendor_id,
        doc_type: data.doc_type || "other",
        requirement_key: reqKey,
        label: file_name || (data.doc_type as string),
        status: "uploaded",
        storage_path: dest,
        file_name,
        mime_type: m,
        issuer: (data.fields as Record<string, unknown>)?.issuer ?? null,
        cert_number: (data.fields as Record<string, unknown>)?.cert_number ?? null,
        issue_date: (data.fields as Record<string, unknown>)?.issue_date ?? null,
        expires_at: (data.fields as Record<string, unknown>)?.expires_at ?? null,
        extracted_data: data,
        uploaded_at: new Date().toISOString(),
      }).select("id").single();
      document_id = ins.data?.id ?? null;
    }

    return json({ ok: true, extraction: data, document_id });
  } catch (e) {
    return json({ ok: false, error: String(e) }, 500);
  }
});
