// 1-Day SaaS Blueprint — Stripe billing webhook (Node, serverless-style handler)
//
// HOT ZONE. Two things here are non-negotiable and must never be "simplified"
// by an autonomous build step:
//   1. Signature verification (stripe.webhooks.constructEvent). Without it,
//      anyone who finds the URL can forge "you're now on the top plan" events.
//   2. Idempotency. Stripe retries and redelivers; processing an event twice
//      double-counts. Record every event id and no-op on repeats.
//
// The raw request body is required for signature verification — do NOT let a
// JSON body-parser consume it first (see BLUEPRINT.md "raw body" gotcha).
//
// Env: STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET, plus service-role DB access.

const Stripe = require('stripe')
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY)

// db: a thin wrapper that uses the SERVICE-ROLE key (bypasses RLS). Billing
// state is written only here — never from any client path.
const db = require('./db')

// The subset of events that change entitlement. Ignore everything else with 200
// so Stripe stops retrying (an unhandled type is not an error).
const HANDLED = new Set([
  'checkout.session.completed',
  'customer.subscription.created',
  'customer.subscription.updated',
  'customer.subscription.deleted',
  'invoice.payment_failed',
])

async function handler(req, res) {
  const sig = req.headers['stripe-signature']
  let event
  try {
    // req.rawBody must be the untouched request body (Buffer/string)
    event = stripe.webhooks.constructEvent(req.rawBody, sig, process.env.STRIPE_WEBHOOK_SECRET)
  } catch (err) {
    console.error('[STRIPE] signature verification failed:', err.message)
    return res.status(400).json({ error: 'invalid signature' })
  }

  // Idempotency: insert-or-skip on the event id.
  const fresh = await db.recordEventIfNew(event.id, event.type)
  if (!fresh) {
    console.log(`[STRIPE] duplicate ${event.id} (${event.type}) — already processed`)
    return res.status(200).json({ received: true, duplicate: true })
  }

  try {
    if (HANDLED.has(event.type)) {
      await process(event)
    } else {
      console.log(`[STRIPE] ignoring unhandled type ${event.type}`)
    }
    await db.markEventProcessed(event.id)
    return res.status(200).json({ received: true })
  } catch (err) {
    // Record the error and return 500 so Stripe retries later.
    console.error(`[STRIPE] processing ${event.id} failed:`, err.message)
    await db.markEventError(event.id, err.message)
    return res.status(500).json({ error: 'processing failed' })
  }
}

async function process(event) {
  const obj = event.data.object

  switch (event.type) {
    case 'checkout.session.completed': {
      // Link the Stripe customer to the org (passed as client_reference_id or
      // metadata at Checkout creation), then pull the subscription.
      const orgId = obj.client_reference_id || obj.metadata?.org_id
      if (!orgId) throw new Error('checkout.session.completed missing org reference')
      if (obj.customer) await db.setOrgCustomer(orgId, obj.customer)
      if (obj.subscription) {
        const sub = await stripe.subscriptions.retrieve(obj.subscription)
        await upsertSubscription(orgId, sub)
      }
      break
    }
    case 'customer.subscription.created':
    case 'customer.subscription.updated':
    case 'customer.subscription.deleted': {
      const orgId = await db.orgIdForCustomer(obj.customer)
      if (!orgId) throw new Error(`no org for customer ${obj.customer}`)
      await upsertSubscription(orgId, obj)
      break
    }
    case 'invoice.payment_failed': {
      const orgId = await db.orgIdForCustomer(obj.customer)
      if (orgId) await db.setSubscriptionStatus(orgId, 'past_due')
      break
    }
  }
}

async function upsertSubscription(orgId, sub) {
  await db.upsertSubscription({
    org_id: orgId,
    stripe_subscription_id: sub.id,
    price_id: sub.items?.data?.[0]?.price?.id ?? null,
    status: sub.status,
    current_period_end: sub.current_period_end
      ? new Date(sub.current_period_end * 1000).toISOString()
      : null,
    cancel_at_period_end: !!sub.cancel_at_period_end,
  })
  console.log(`[STRIPE] org ${orgId} → ${sub.status} (${sub.id})`)
}

module.exports = { handler }
