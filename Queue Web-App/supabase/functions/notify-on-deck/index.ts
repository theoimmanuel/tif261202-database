// supabase/functions/notify-on-deck/index.ts
//
// Deploy with:  supabase functions deploy notify-on-deck
// Then wire it to the `queue` table with a Database Webhook
// (Dashboard → Database → Webhooks → New webhook):
//   Table: queue | Events: Insert, Update | Type: Edge Function
//   Function: notify-on-deck
//
// Needs two secrets set first:
//   supabase secrets set RESEND_API_KEY=your_resend_key
//   supabase secrets set NOTIFY_FROM_EMAIL="Call Sheet <queue@yourdomain.dev>"
//   supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
//   (SUPABASE_URL is provided automatically in the function's environment)

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY")!;
const FROM_EMAIL = Deno.env.get("NOTIFY_FROM_EMAIL") ?? "queue@yourdomain.dev";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? Deno.env.get("SUPABASE_ANON_KEY")!;

const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

Deno.serve(async (req) => {
  const payload = await req.json();
  const record = payload.record;

  // Only email the person who just became "on deck" (position 2),
  // only if they gave an email, and only once.
  if (!record || record.position !== 2 || !record.notify_email || record.notified) {
    return new Response("skip", { status: 200 });
  }

  const emailRes = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${RESEND_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      from: FROM_EMAIL,
      to: record.notify_email,
      subject: "You're up next",
      text:
        `Hi ${record.name},\n\n` +
        `You're on deck — the current presenter is up now, so you're next. ` +
        `Good luck!\n\n— Call Sheet`,
    }),
  });

  if (!emailRes.ok) {
    const err = await emailRes.text();
    return new Response(`email failed: ${err}`, { status: 500 });
  }

  await supabase.from("queue").update({ notified: true }).eq("id", record.id);

  return new Response("sent", { status: 200 });
});
