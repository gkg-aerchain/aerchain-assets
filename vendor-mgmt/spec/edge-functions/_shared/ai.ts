// Provider-agnostic AI gateway for Supabase Edge Functions (Deno).
// Default provider = OpenAI; falls back to Gemini, then Anthropic, if configured.
// Supports text + vision + JSON-mode. Keys live in edge-function secrets.
//
//   AI_PROVIDER      "openai" | "gemini" | "anthropic"   (default "openai")
//   OPENAI_API_KEY   gpt-4o (vision/json), gpt-4o-mini (cheap text)
//   GEMINI_API_KEY   gemini-2.5-flash
//   ANTHROPIC_API_KEY claude-sonnet-4-6

export type AIImage = { mime: string; base64: string };
export type AIArgs = {
  system?: string;
  prompt: string;
  images?: AIImage[];
  json?: boolean;           // force JSON object output
  maxTokens?: number;
};

const ORDER = (): string[] => {
  const primary = (Deno.env.get("AI_PROVIDER") || "openai").toLowerCase();
  const all = ["openai", "gemini", "anthropic"];
  return [primary, ...all.filter((p) => p !== primary)];
};

export async function callAI(args: AIArgs): Promise<{ text: string; provider: string; degraded: boolean }> {
  let lastErr: unknown;
  for (const provider of ORDER()) {
    try {
      const key = keyFor(provider);
      if (!key) continue;
      const text = await dispatch(provider, key, args);
      return { text, provider, degraded: false };
    } catch (e) {
      lastErr = e;
      console.error(`[ai] ${provider} failed:`, e);
    }
  }
  // total failure → degraded; caller decides fallback (e.g. mock data)
  return { text: "", provider: "none", degraded: true };
}

// Convenience: parse JSON out of the model response (tolerant of code fences).
export async function callAIJSON<T = unknown>(args: AIArgs): Promise<{ data: T | null; provider: string; degraded: boolean }> {
  const r = await callAI({ ...args, json: true });
  if (r.degraded || !r.text) return { data: null, provider: r.provider, degraded: r.degraded };
  try {
    const cleaned = r.text.replace(/^```(json)?/i, "").replace(/```$/, "").trim();
    return { data: JSON.parse(cleaned) as T, provider: r.provider, degraded: false };
  } catch (_e) {
    return { data: null, provider: r.provider, degraded: true };
  }
}

function keyFor(p: string): string | undefined {
  if (p === "openai") return Deno.env.get("OPENAI_API_KEY") || undefined;
  if (p === "gemini") return Deno.env.get("GEMINI_API_KEY") || undefined;
  if (p === "anthropic") return Deno.env.get("ANTHROPIC_API_KEY") || undefined;
  return undefined;
}

async function dispatch(provider: string, key: string, a: AIArgs): Promise<string> {
  if (provider === "openai") return openai(key, a);
  if (provider === "gemini") return gemini(key, a);
  if (provider === "anthropic") return anthropic(key, a);
  throw new Error("unknown provider " + provider);
}

// ---- OpenAI (chat completions; vision via image_url data URLs) ----
async function openai(key: string, a: AIArgs): Promise<string> {
  const content: unknown[] = [{ type: "text", text: a.prompt }];
  for (const img of a.images || []) {
    content.push({ type: "image_url", image_url: { url: `data:${img.mime};base64,${img.base64}` } });
  }
  const body: Record<string, unknown> = {
    model: a.images?.length ? "gpt-4o" : "gpt-4o-mini",
    messages: [
      ...(a.system ? [{ role: "system", content: a.system }] : []),
      { role: "user", content },
    ],
    max_tokens: a.maxTokens ?? 1500,
    temperature: 0.2,
  };
  if (a.json) body.response_format = { type: "json_object" };
  const res = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: { Authorization: `Bearer ${key}`, "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  if (!res.ok) throw new Error(`openai ${res.status}: ${await res.text()}`);
  const j = await res.json();
  return j.choices?.[0]?.message?.content ?? "";
}

// ---- Gemini (generateContent; inline_data for images) ----
async function gemini(key: string, a: AIArgs): Promise<string> {
  const parts: unknown[] = [{ text: (a.system ? a.system + "\n\n" : "") + a.prompt + (a.json ? "\n\nReturn ONLY valid JSON." : "") }];
  for (const img of a.images || []) parts.push({ inline_data: { mime_type: img.mime, data: img.base64 } });
  const model = "gemini-2.5-flash";
  const res = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${key}`,
    { method: "POST", headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ contents: [{ parts }], generationConfig: { temperature: 0.2,
        ...(a.json ? { responseMimeType: "application/json" } : {}) } }) });
  if (!res.ok) throw new Error(`gemini ${res.status}: ${await res.text()}`);
  const j = await res.json();
  return j.candidates?.[0]?.content?.parts?.map((p: { text?: string }) => p.text).join("") ?? "";
}

// ---- Anthropic (messages; base64 image blocks) ----
async function anthropic(key: string, a: AIArgs): Promise<string> {
  const content: unknown[] = [{ type: "text", text: a.prompt + (a.json ? "\n\nReturn ONLY valid JSON." : "") }];
  for (const img of a.images || []) content.push({ type: "image", source: { type: "base64", media_type: img.mime, data: img.base64 } });
  const res = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: { "x-api-key": key, "anthropic-version": "2023-06-01", "Content-Type": "application/json" },
    body: JSON.stringify({ model: "claude-sonnet-4-6", max_tokens: a.maxTokens ?? 1500,
      system: a.system, messages: [{ role: "user", content }] }),
  });
  if (!res.ok) throw new Error(`anthropic ${res.status}: ${await res.text()}`);
  const j = await res.json();
  return j.content?.[0]?.text ?? "";
}
