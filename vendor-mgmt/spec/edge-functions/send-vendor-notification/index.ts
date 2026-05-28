// send-vendor-notification — in-app notification rows + best-effort email (Resend).
// The DB state machine (vendor_transition) already writes in-app notifications for
// lifecycle events; this function adds EMAIL and handles events with no app user yet
// (e.g. invitation_sent to a brand-new vendor email).
//
// POST {
//   type, vendor_id?, org_id?,
//   recipient_ids?: string[],         // auth uids -> in-app notifications
//   recipient_emails?: string[],      // -> email
//   title?, body?, link?,             // override the template
//   data?: Record<string,string>,     // template variables ({{company}}, {{token}}, ...)
//   email?: boolean                   // default true
// }
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { preflight, json } from "../_shared/cors.ts";

type Tmpl = { subject: string; body: (d: Record<string, string>) => string };
const T: Record<string, Tmpl> = {
  invitation_sent:        { subject: "You're invited to register as a supplier", body: (d) => `${d.org ?? "A buyer"} invited ${d.company ?? "your company"} to register on Aerchain. Start here: ${d.link ?? ""}` },
  registration_submitted: { subject: "Registration submitted", body: (d) => `${d.company ?? "A vendor"} submitted their registration for review.` },
  approval_needed:        { subject: "Vendor approval needed", body: (d) => `${d.company ?? "A vendor"} is ready for review and approval. ${d.link ?? ""}` },
  vendor_approved:        { subject: "Your registration was approved", body: (d) => `Congratulations — you're now an approved supplier for ${d.org ?? "the buyer"}. Vendor code: ${d.code ?? ""}.` },
  vendor_rejected:        { subject: "Registration update", body: (d) => `Your registration was not approved. ${d.reason ?? ""}` },
  changes_requested:      { subject: "Changes requested on your registration", body: (d) => `Please review and resubmit. ${d.reason ?? ""} ${d.link ?? ""}` },
  document_expiring:      { subject: "A document is expiring soon", body: (d) => `${d.doc ?? "A document"} expires on ${d.expires ?? "soon"}. Please re-upload. ${d.link ?? ""}` },
  reupload_reminder:      { subject: "Action needed: re-upload a document", body: (d) => `Please re-upload ${d.doc ?? "a document"}. ${d.link ?? ""}` },
  document_rejected:      { subject: "A document needs attention", body: (d) => `${d.doc ?? "A document"} was rejected. ${d.reason ?? ""}` },
  message_received:       { subject: "New message", body: (d) => `You have a new message from ${d.from ?? "your counterpart"}.` },
  screening_complete:     { subject: "Risk screening complete", body: (d) => `Screening finished for ${d.company ?? "a vendor"}.` },
  evaluation_assigned:    { subject: "You have an evaluation to complete", body: (d) => `An evaluation for ${d.company ?? "a vendor"} was assigned to you. ${d.link ?? ""}` },
  vendor_blocked:         { subject: "Account status changed", body: (d) => `Your account was blocked. ${d.reason ?? ""}` },
  vendor_unblocked:       { subject: "Account reactivated", body: () => `Your account has been reactivated.` },
};

Deno.serve(async (req) => {
  const pf = preflight(req); if (pf) return pf;
  try {
    const p = await req.json();
    const tmpl = T[p.type];
    const subject = p.title ?? tmpl?.subject ?? "Notification";
    const bodyText = p.body ?? (tmpl ? tmpl.body({ ...(p.data ?? {}), link: p.link ?? "" }) : "");

    const supa = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);

    // in-app
    if (Array.isArray(p.recipient_ids) && p.recipient_ids.length) {
      await supa.from("notifications").insert(p.recipient_ids.map((rid: string) => ({
        recipient_id: rid, org_id: p.org_id ?? null, vendor_id: p.vendor_id ?? null,
        type: p.type, title: subject, body: bodyText, link: p.link ?? null,
      })));
    }

    // email (best-effort)
    let emailed = false;
    const RESEND = Deno.env.get("RESEND_API_KEY");
    const emails: string[] = p.email === false ? [] : (p.recipient_emails ?? []);
    if (RESEND && emails.length) {
      const res = await fetch("https://api.resend.com/emails", {
        method: "POST",
        headers: { Authorization: `Bearer ${RESEND}`, "Content-Type": "application/json" },
        body: JSON.stringify({
          from: Deno.env.get("NOTIFY_FROM") ?? "Aerchain <noreply@aerchain.io>",
          to: emails, subject,
          html: `<div style="font-family:DM Sans,Arial,sans-serif;font-size:15px;color:#1f2430">${bodyText}</div>`,
        }),
      });
      emailed = res.ok;
      if (!res.ok) console.error("resend failed", await res.text());
    }

    return json({ ok: true, emailed });
  } catch (e) {
    return json({ ok: false, error: String(e) }, 500);
  }
});
