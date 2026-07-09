# 1-Day SaaS Blueprint

An end-to-end boilerplate for shipping a multi-tenant micro-SaaS in a day by
driving a lower-cost model against a loaded operating manual. Part of the
`use-claude-for-projects` library — it inherits this repo's disciplines
(operating manual, checkable quality bars, hot zones, learning law) and applies
them to the specific shape of a subscription SaaS.

## What's in here

| File | Role |
|---|---|
| `system-prompts.md` | The builder system prompt + ordered phase prompts that drive the build. Start here. |
| `schema.sql` | PostgreSQL/Supabase multi-tenant schema with RLS and Stripe-mirror billing. |
| `stripe-webhook.js` | The billing webhook — signature-verified, idempotent. The hot zone. |

## Architecture (deliberately boring — boring ships)

```
 Browser ──► App (Next.js/serverless)
                │        │
                │        └─► Stripe Checkout (hosted) ──► card entry
                ▼
          Postgres (RLS)  ◄── Stripe webhook (service-role writes billing)
                ▲                     ▲
                │                     │
        tenant-scoped reads     signed + idempotent events
```

- **Auth provider** issues user identities (Supabase Auth, Clerk, etc.).
- **Postgres with RLS** is the tenant boundary: a user sees only their org's rows.
- **Stripe is the source of truth for billing**; our `subscriptions` table is a
  downstream mirror, written **only** by the verified webhook.
- **Entitlement is server-side**: every gated action asks `org_is_active(org)`.

## The 1-day sequence

Run the phase prompts in `system-prompts.md` in order: scaffold+backup → schema
→ auth/tenancy → **billing (human-review stop)** → entitlement gating → ship.
Each phase has a checkable "done" — don't advance until its evidence is shown.

## Why this is a *safe* autonomous build, not just a fast one

This library's transplant test proved a cheaper model follows a good manual
precisely — but only when it (a) loads the manual, (b) has checkable "done"
criteria, and (c) is stopped at hot zones. This blueprint encodes all three.
The billing phase is explicitly human-reviewed and forbids weakening signature
verification or idempotency, because that is exactly where an unsupervised model
silently loses you money.

## Gotchas this boilerplate already handles (so you don't relearn them)

1. **Stripe redelivers events.** Every event id is recorded; repeats no-op.
   Without this, one webhook retry double-provisions or double-charges logic.
2. **Signature verification needs the raw body.** A JSON body-parser that runs
   first corrupts the payload and every event 400s. Preserve `req.rawBody`.
3. **Never trust the client for entitlement.** A paywall enforced in the browser
   is not enforced. Gate on `org_is_active` server-side.
4. **Billing writes are service-role only.** No client path may write
   `subscriptions`; RLS + a webhook-only writer is the whole security model.
5. **Env changes need a redeploy.** Setting `STRIPE_WEBHOOK_SECRET` in the host
   dashboard does nothing until you redeploy.
6. **One org can have one live subscription** (schema `unique(org_id)`); revisit
   only if you sell add-on subscriptions.

## Scope / honesty

This is engineering boilerplate, not a business. It gets a correct, secure,
billable SaaS skeleton stood up fast. Product-market fit, support, refunds,
tax (Stripe Tax), and dunning are yours. The billing hot zone is real money —
review it with a human before going live, every time.
