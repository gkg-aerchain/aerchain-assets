# 9. Execution plan (hour-by-hour) & 10. Demo-day kill-switches

> Ordered so the **demo script** (`02-DEMO-SCRIPT.md`) is runnable end-to-end as
> early as possible (≈ T+10h), then everything else is layered on. All features
> ship — this is sequence, not scope.

## 9. T+0 → T+24

| Block | Hours | Work | Output |
|------|------|------|--------|
| **Schema** | T+0 → T+2 | Apply `0001` (enums, tables, grants), `0002` (functions, triggers, state machine), `0003` (RPCs). | DB stands up; `vendor_transition`, RPCs callable. |
| **RLS + storage + realtime** | T+2 → T+4 | Apply `0004` (RLS), `0005` (bucket, storage policies, realtime publication). | Multi-user isolation enforced; bucket ready. |
| **Seed** | T+4 → T+5 | Apply `0006` seed; create 5 auth users; `select link_demo_users();`. | App looks populated; Tata 360 depth; Bharat Forge `invited` w/ token; Asian Paints expiring doc. |
| **Buyer P0 UI** | T+5 → T+8 | Wire `/vendors` (tabs/KPIs/filters), `/vendors/prospects` (+ Add Prospect → `invite_vendor`), 360 Registration tab, header **Approve/Reject/Block** → `vendor_transition`. | Buyer can invite + review + decide for real. |
| **Vendor P0 UI** | T+8 → T+11 | `/portal/adani` (self-register + invite), `/vendor/auth` (claim), `/vendor/onboard` wired with **autosave** + Submit → `vendor_transition`; Documents step uses Storage + `vendor_document_checklist`. | **Demo script Acts 1–3 runnable end-to-end.** |
| **Realtime + notifications** | T+11 → T+13 | Subscriptions (vendors/messages/notifications), toast+bell, `send-vendor-notification` wired to invite/submit/approve. | Cross-user <5s; emails fire. |
| **AI doc-extraction + MCA** | T+13 → T+16 | Deploy `_shared`, `extract-document`, `mca-fetch`; wire dropzone auto-map + Auto-Fetch + Auto-Fill Demo. | Wow #2 + MCA live. |
| **Risk + Web Insights + DD** | T+16 → T+19 | Deploy `risk-screening`, `vendor-web-insights`; wire Web Insights *Refresh Now*, sanctions/PEP cards; DD gate on Approve. | Wow #4 + due-diligence gate. |
| **Evaluation + assistant** | T+19 → T+21 | Wire Evaluation tab (Add Evaluation, score → recompute, `ai-evaluate` suggest); `vendor-assistant` panel. | Scorecard real; AI scoring. |
| **P1/P2 polish** | T+21 → T+23 | Business Overview charts, Hierarchy tab, vendor dashboard/workspace/PO, expiry-sweep + reminder, audit drawer, messaging. | Full breadth. |
| **QA + dry run** | T+23 → T+24 | Run the demo script twice in two browsers; fix breakages; verify refresh-persistence + RLS (vendor can't see other vendors). | Green run. |

## Top-3 risks + fallback

1. **AI/vision latency or quota during live demo.**
   *Fallback:* `RISK_MODE=mock` + **Auto-Fill Demo** button → deterministic fill and
   "Clean" screenings with zero external calls. Pre-warm by running the dossier on
   Bharat Forge once before the demo (it caches in `vendor_web_insights`).
2. **Auth-user ↔ role linkage (`org_users`/`roles` schema mismatch).**
   *Fallback:* `link_demo_users()` is editable; if the roles table differs, seed
   roles manually for the 5 demo accounts. Verify `has_role(uid,'buyer_admin')`
   returns true for Priya before the demo.
3. **Realtime not delivering (publication/replica identity).**
   *Fallback:* the UI also re-fetches on window focus + a 5s poll on the 360/list as
   a safety net; if realtime is dead the tick still appears within 5s.

## 10. Demo-day kill-switches

Feature flags (env/config, read at boot) — flip OFF to hide and route around:

| Flag | OFF behaviour |
|------|---------------|
| `FLAG_AI_EXTRACTION` | Hide the dropzone; vendor fills the form manually (still real). |
| `FLAG_WEB_INSIGHTS` | Hide *Refresh Now*; show the **seeded** Tata dossier (already in `vendor_web_insights`). |
| `FLAG_LIVE_RISK` | Force `RISK_MODE=mock`. |
| `FLAG_EMAIL` | Skip `send-vendor-notification` email; in-app notifications still fire. |
| `FLAG_ASSISTANT` | Hide the Aiera panel. |

Fallback routes: if `/vendor/onboard` autosave misbehaves, the **Auto-Fill Demo**
button fills + the Submit still calls `vendor_transition`. If the public portal
errors, paste the invitation link straight into `/vendor/auth?invite=demo-bharatforge-token`.

**Presenter recovery lines (say verbatim):**
> "We run this against a live database with real role-based access — so I'll let the
> data refresh for a second rather than show you a mock."
> "And while that syncs, notice everything you've seen already persisted — I can
> reload either window and the state is exactly where we left it."
