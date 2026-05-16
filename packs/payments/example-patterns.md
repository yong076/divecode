# example-patterns — payments

## Idempotency key on every Stripe call

```typescript
const intent = await stripe.paymentIntents.create(
  { amount: 5000, currency: 'usd', customer: customerId },
  { idempotencyKey: `checkout-${userId}-${cartId}` }
);
```

## Webhook handler — signature + dedupe + dispatch

```typescript
export async function POST(req: Request) {
  const sig = req.headers.get('stripe-signature')!;
  const body = await req.text();
  let event;
  try {
    event = stripe.webhooks.constructEvent(body, sig, WEBHOOK_SECRET);
  } catch {
    return new Response('bad sig', { status: 401 });
  }

  // Dedupe by event.id
  const inserted = await db.processed_events.upsert({
    id: event.id, processed_at: new Date(),
  }, { ignoreConflict: true });
  if (!inserted) return new Response('duplicate', { status: 200 });

  switch (event.type) {
    case 'customer.subscription.updated':
    case 'customer.subscription.deleted':
      await syncSubscription(event.data.object); break;
    case 'invoice.paid':
      await grantEntitlement(event.data.object); break;
    case 'invoice.payment_failed':
      await sendDunningEmail(event.data.object); break;
    case 'charge.refunded':
      await revokeAccess(event.data.object); break;
  }

  return new Response('ok');
}
```

## Source-of-truth pattern (mirror, don't duplicate)

```typescript
// DB row mirrors Stripe — keyed by Stripe IDs, refreshed on every webhook
type Subscription = {
  stripe_subscription_id: string;   // PK
  stripe_customer_id: string;
  status: 'trialing' | 'active' | 'past_due' | 'canceled';
  current_period_end: Date;
  plan_id: string;
  updated_at: Date;
};

// Access check uses DB (fast). Drift detection job reconciles nightly.
function hasProAccess(userId: string): boolean {
  const sub = db.subscription.findByUser(userId);
  return sub && ['trialing', 'active', 'past_due'].includes(sub.status);
}
```

## Nightly drift reconciliation

```typescript
// Cron: nightly
for (const localSub of await db.subscriptions.activeOnes()) {
  const remote = await stripe.subscriptions.retrieve(localSub.stripe_subscription_id);
  if (remote.status !== localSub.status) {
    await db.subscriptions.update(localSub.id, { status: remote.status });
    await alert('drift_detected', { id: localSub.id, local: localSub.status, remote: remote.status });
  }
}
```
