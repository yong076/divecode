# failure-modes — vercel-serverless

## Function timeout on slow downstream
External API takes 12s. Your function timeout is 10s. Request 504s. The external work already happened (charged the user, sent the email) but you can't tell the client.

**Detection**: requests that succeed externally but error to user; mismatched state.

## Cron job overlap
Cron runs every 5 minutes. Sometimes it takes 8 minutes. Now two runs are processing the same data. Whichever finishes second overwrites whichever finishes first. Or both create duplicate side effects.

**Detection**: duplicated work or last-writer-wins surprises after cron-heavy hours.

## Cold start latency spike on first user of the day
First user at 8am hits a cold function. Their request takes 4s instead of 200ms. They blame the product. Subsequent users see normal latency.

**Detection**: latency p99 has periodic spikes correlating with low-traffic gaps.

## Connection storm on traffic burst
Spike to 500 concurrent function invocations. Each opens its own DB connection. DB max_connections = 100. Most invocations fail with "too many connections."

**Detection**: 500-error rate correlates with traffic spikes; DB logs show connection refusals.

## Webhook replay
External service times out waiting for your response (because YOUR function timed out). They retry. You process the same webhook twice.

**Detection**: duplicate side effects from webhooks; identical idempotency keys arriving twice.

## ISR revalidation thundering herd
Page has 60s revalidation. After 60s + 1ms, the next 1000 requests in the same second all trigger revalidation simultaneously. Your origin sees the spike.

**Detection**: revalidation latency spikes; origin LB shows synchronized waves.

## Edge runtime missing dep
You added a package that uses Node APIs. Works in `next dev`. Fails in production with cryptic Edge runtime error.

**Detection**: deploy succeeds but specific endpoints return 500 in prod.

## Function logs disappear past retention
Bug happened 3 days ago. Vercel free tier logs only kept 24h. No evidence of what went wrong.

**Detection**: post-incident investigation hits a wall.
