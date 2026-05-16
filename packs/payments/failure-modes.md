# failure-modes — payments

## Duplicate charge from missing idempotency key
Network hiccup mid-checkout. Client retries. Backend creates a new payment intent (no idempotency key). User charged twice.

**Detection**: duplicate charges within seconds for same user; angry tweets.

## Webhook arrived twice, processed twice
Provider retries webhook. You don't dedupe by `event.id`. User's subscription gets activated twice → either crashes (unique constraint) or double-grants entitlements.

**Detection**: subscription duplicates; double-credited account.

## Source-of-truth drift
Your DB says user is on Pro plan. Stripe says they're on Free. Whose source is right? If you grant access based on YOUR DB, user gets free Pro. If you check Stripe on every request, latency tanks.

**Detection**: support tickets like "I'm being charged but don't have access" or "I cancelled but still being charged."

## Webhook gap allows entitlement
User paid. Provider sends webhook. Webhook delayed 3 hours. During those 3 hours user gets no Pro access. Refund-and-cancel ensues.

**Detection**: support tickets about "I paid but…"; webhook delivery latency metrics.

## 3DS popup dismissed
User starts checkout. 3DS popup appears. User closes it accidentally. Backend has a payment intent in "requires_action" state forever. User retries: payment intent still pending. Multiple stale intents accumulate.

**Detection**: high count of payment intents stuck in `requires_action`.

## Refund without access revocation
Support refunds via Stripe dashboard. Your app keeps showing access because no webhook handler for `charge.refunded`. User keeps using Pro post-refund.

**Detection**: count of refunded users still actively using paid features.

## Test webhook in prod
Webhook endpoint accepts both test and live signing secrets. Bad actor sends synthetic "subscription created" webhook with test signature. Grants free Pro.

**Detection**: rare. Prevent by separating endpoints.

## Tax calculation drift
You hardcoded sales tax rates. Rates changed. You undercharge. Owe tax authority back-tax.

**Detection**: tax filing.

## Dunning silently fails
Card expired. Provider tries to charge, fails. Provider sends `invoice.payment_failed`. You don't handle it. User churns silently, no recovery email.

**Detection**: cohort retention drops mysteriously.
