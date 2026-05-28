// vendor-assistant ("Aiera") — onboarding chat helper. Answers questions and can
// instruct the client to fill a named field.
// POST { vendor_id, messages:[{role,content}], context? }
//   -> { ok, reply, action?: { type:"fill", field:string, value:string } }
import { preflight, json } from "../_shared/cors.ts";
import { callAIJSON } from "../_shared/ai.ts";

Deno.serve(async (req) => {
  const pf = preflight(req); if (pf) return pf;
  try {
    const { messages, context } = await req.json();
    const convo = (messages ?? []).map((m: { role: string; content: string }) => `${m.role}: ${m.content}`).join("\n");

    const { data, degraded } = await callAIJSON<{ reply: string; action?: unknown }>({
      system: "You are Aiera, Aerchain's vendor-onboarding assistant. Be concise and practical. " +
              "If the user asks you to fill a field, respond with JSON {reply, action:{type:'fill',field,value}}. " +
              "Otherwise {reply}. JSON only.",
      prompt: `Onboarding context: ${JSON.stringify(context ?? {})}\nConversation:\n${convo}\n\nRespond as JSON.`,
      json: true,
    });
    if (degraded || !data) return json({ ok: true, reply: "I'm having trouble right now — please fill this field manually." });
    return json({ ok: true, reply: data.reply, action: (data as { action?: unknown }).action });
  } catch (e) {
    return json({ ok: false, error: String(e) }, 500);
  }
});
