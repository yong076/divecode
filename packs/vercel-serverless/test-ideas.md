# test-ideas — vercel-serverless

## Timeout simulation
Set downstream to delay 11s. Hit your endpoint. Assert it returns a graceful timeout response (not 504 from the platform) — your code must catch the slow path and return early.

## Cron idempotency
Manually run the cron handler twice in a row. Assert side effects happen at most once (idempotency key check, or natural idempotency).

## Cold start envelope
Cold-invoke each function. Assert cold start latency is within budget (e.g., < 1s for user-facing routes).

## Connection pool under concurrent invocations
Spawn 100 parallel function invocations against a DB-touching endpoint. Assert success rate is 100% (proves your pooler/HTTP driver handles burst correctly).

## Webhook replay protection
Send the same webhook payload twice with the same signature. Assert exactly one side effect occurred.

## Edge runtime smoke
For every Edge-runtime route, deploy preview + curl it. Assert it returns 200, not Edge runtime error.
