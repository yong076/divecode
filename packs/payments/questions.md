# questions — payments

## Source of truth
- The provider (Stripe, Paddle, ...) is the source of truth for: which customers exist, which subscriptions are active, what was paid, what was refunded. Is your DB schema consistent with that?
- What's in your DB vs what's in the provider? (Don't duplicate billing state — mirror it, with provider IDs as keys.)

## Webhooks
- Which events drive your DB updates? (`invoice.paid`, `customer.subscription.updated`, etc. — list them)
- HMAC signature verified on every webhook?
- Replay protection? (idempotency key from provider, or `event.id` dedupe)
- What if webhook delivery is delayed by hours? Does your app handle "user paid but webhook hasn't arrived yet"?
- Webhook retry semantics — does the provider retry on 5xx? You return what?

## Subscription lifecycle
- Trial → active → past_due → canceled → reactivated paths all handled?
- Grace period for past_due? Soft cancel vs hard cancel?
- Dunning emails — yours or the provider's?
- Proration on plan change — how is it surfaced to the user?

## Refunds & disputes
- Full vs partial refund policy?
- Who initiates refund — support tool, customer self-serve, automated?
- Chargeback (forced refund + fee) workflow?
- Refund affects access immediately or at period end?

## SCA / 3DS
- Strong Customer Authentication required in user's region?
- 3D Secure challenge flow handled?
- What happens when user closes the 3DS popup mid-flow?

## PII & PCI
- Card number ever touches your servers? (Should be: never. Use provider's hosted form / token.)
- Storing customer email / billing address — covered by your privacy policy?
- PCI scope minimized? (provider attestation sufficient for your use case?)

## Idempotency
- Idempotency keys on every payment intent / charge creation?
- Retry-safe: same key + same params = same result, not duplicate charge?

## Test mode
- Test keys vs live keys clearly separated in env? Hard to confuse?
- Webhook endpoints distinct for test vs live?

## Edge cases
- Partial month / partial year subscription start — proration?
- Upgrade vs downgrade — when does the new price apply?
- Multi-currency? Tax handling? (or use provider's tax service)
