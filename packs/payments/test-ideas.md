# test-ideas — payments

## Idempotency
Call payment intent creation twice with same key. Assert only one charge created (provider deduplicates), same result returned both times.

## Webhook replay
Send same webhook event twice. Assert side effects happen exactly once.

## Webhook signature
Send webhook with wrong signature. Assert 401 and no side effect.

## Source-of-truth drift detection
Nightly job: for each subscription in your DB, fetch from provider. Assert state matches. Alert on drift.

## 3DS dropoff
Simulate 3DS challenge timeout. Assert payment intent transitions to documented terminal state (canceled), not orphaned.

## Refund cascade
Trigger refund via webhook. Assert access revoked within N seconds. Assert user notified.

## Test/live key separation
Assert webhook handler rejects events signed with test secret when running in live mode.

## Dunning recovery path
Simulate `invoice.payment_failed`. Assert email sent. Simulate `invoice.paid` after retry. Assert access restored.
