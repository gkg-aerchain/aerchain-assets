# Aerchain Vendor Management & Due Diligence — Spec Package

Complete, build-ready spec for a **fully working** vendor management + due-diligence
module (React 18 + Vite + Tailwind + shadcn/ui + Supabase). Built to be fed into
Lovable. **No features cut.** Designed to match the existing `demo.aerchain.io` shell
exactly (analyzed from 20 screenshots) and to serve the **Adani-on-Aerchain** tenancy
model with AI doc-extraction, third-party risk screening, and a due-diligence gate.

## Read / apply in this order
1. **`00-OVERVIEW.md`** — architecture, multi-tenancy (Aerchain platform / Adani tenant), roles, AI provider strategy, conventions, assumptions.
2. **`01-SCOPE.md`** — full feature set as P0/P1/P2 build order (nothing cut).
3. **`02-DEMO-SCRIPT.md`** — the north star (10-min two-window walkthrough). The app is done when this runs.
4. **`migrations/0001_schema.sql` → `0006_seed.sql`** — apply as Supabase migrations:
   - `0001_schema.sql` enums + tables + grants + enable RLS
   - `0002_functions_triggers.sql` updated_at, state machine `vendor_transition()`, scorecard recompute
   - `0003_rpcs.sql` portal/invitation/onboarding RPCs (safe public entry points)
   - `0004_rls.sql` row-level security policies
   - `0005_storage_realtime.sql` `vendor-documents` bucket + storage policies + realtime publication
   - `0006_seed.sql` 10 lifecycle vendors + 6 prospects + Tata Steel 360 depth + demo users
5. **`03-RBAC.md`**, **`04-STATE-MACHINE.md`** — access matrix + lifecycle reference.
6. **`05-SCREENS.md`** — screen-by-screen wiring (existing tabs + net-new Adani portal, vendor dashboard/workspace/PO).
7. **`06-AI-RISK-DUEDILIGENCE.md`** + **`edge-functions/`** — deploy edge functions; wire AI extraction, MCA, Web Insights, risk screening, evaluation AI, assistant.
8. **`07-REALTIME-NOTIFICATIONS.md`** — realtime channels + `send-vendor-notification`.
9. **`08-EXECUTION-AND-KILLSWITCH.md`** — hour-by-hour build plan + demo-day fallbacks.

## Lovable kickoff prompt (paste first)
> Build a Vendor Management + Due Diligence module on our existing React 18 + Vite +
> Tailwind + shadcn + Supabase app, matching the current `/vendors` and `/vendor/*`
> design exactly. Apply the SQL migrations in `vendor-mgmt/spec/migrations/` in order
> (0001→0006). Then deploy the edge functions in `vendor-mgmt/spec/edge-functions/`
> and set their secrets (default AI provider = OpenAI; `RISK_MODE=mock`). Then wire the
> screens per `05-SCREENS.md`, the realtime/notifications per `07`, and the AI/risk/DD
> per `06`. Multi-tenant: Aerchain is the platform, **Adani** is the buyer tenant; the
> public Adani portal (`/portal/adani`) redirects vendors into the Aerchain-branded
> onboarding. Acceptance = the demo script in `02-DEMO-SCRIPT.md` runs end-to-end across
> two browser windows with real persistence and role-based access. Do not cut features.

## Status of inputs
- Reference screenshots (20) live on `main` under `vendor-mgmt/screenshots/` (gitignored on this branch).
- Net-new screens (no existing capture): Adani portal `/portal/:slug`, vendor `/dashboard`, `/workspace/:customerId`, `/purchase-orders` — specced in `05-SCREENS.md`, to be built in the same design language.
