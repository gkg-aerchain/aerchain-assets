# Edge functions — deploy & secrets

Deno functions for Supabase. Folder per function; `_shared/` is imported, not deployed
standalone. All return CORS headers and a `{ ok, ... }` envelope.

## Deploy
```bash
supabase functions deploy extract-document
supabase functions deploy mca-fetch
supabase functions deploy risk-screening
supabase functions deploy vendor-web-insights
supabase functions deploy ai-evaluate
supabase functions deploy vendor-assistant
supabase functions deploy send-vendor-notification
# (expiry-sweep optional, schedule via pg_cron or an external scheduler)
```
> In Lovable, add each as a Supabase Edge Function with the file contents here.
> `_shared/cors.ts` and `_shared/ai.ts` go alongside (relative import `../_shared/…`).

## Secrets (Supabase → Edge Functions → Secrets)
| Secret | Required | Purpose |
|--------|----------|---------|
| `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY` | yes | DB + Storage access from functions |
| `AI_PROVIDER` | no (default `openai`) | `openai` \| `gemini` \| `anthropic` |
| `OPENAI_API_KEY` | yes (default provider) | extraction (vision), dossier, evaluate, assistant |
| `GEMINI_API_KEY` | recommended | fallback provider |
| `ANTHROPIC_API_KEY` | optional | optional provider |
| `RISK_MODE` | no (default `mock`) | `mock` (demo-safe) \| `live` |
| `OPENSANCTIONS_API_KEY` | only for live sanctions/PEP | OpenSanctions match API |
| `NEWS_API_KEY`, `DNB_API_KEY`, `MCA_API_KEY` | only for live | news / credit / MCA adapters |
| `RESEND_API_KEY`, `NOTIFY_FROM` | for email | outbound email (best-effort) |

## Function contracts (quick ref)
- `extract-document`  `{vendor_id, storage_path, mime, file_name?, save?}` → `{ok, extraction, document_id}`
- `mca-fetch`         `{pan?, cin?, legal_name?}` → `{ok, source, data}`
- `risk-screening`    `{vendor_id, types?, mode?}` → `{ok, mode, flagged, screenings[]}`
- `vendor-web-insights` `{vendor_id}` → `{ok, degraded, sanctions, pep}` (persists dossier)
- `ai-evaluate`       `{vendor_id, dimensions[]}` → `{ok, lines[]}`
- `vendor-assistant`  `{vendor_id, messages[], context?}` → `{ok, reply, action?}`
- `send-vendor-notification` see `../07-REALTIME-NOTIFICATIONS.md`

## Demo safety
With `RISK_MODE=mock` and the **Auto-Fill Demo** button, the whole flow runs with no
external network dependency and deterministic output. Switch `RISK_MODE=live` and add
keys to use real providers.
