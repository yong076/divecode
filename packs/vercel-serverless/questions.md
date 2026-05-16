# questions — vercel-serverless

## Timeouts
- Function timeout per route? (Hobby: 10s, Pro: 60s, Enterprise: 900s — depending on runtime)
- What happens to in-flight work when timeout hits? (orphan DB row? partial Stripe call?)
- Long-running operations: are they on a queue, not in the request path?

## Cold starts
- Which runtime: Edge (fast cold start, smaller capabilities) or Node (richer but slower start)?
- Cold start impact on user-facing latency? (often hidden by traffic, exposed at low traffic)
- Function size budget? (cold start scales with bundle size)

## Cron jobs
- Cron frequency? (Vercel Hobby: daily only; Pro: per-minute)
- What if a cron run is still in flight when the next is scheduled? (overlap, or skip?)
- Cron idempotency — running it twice is safe?
- Time zone of the cron schedule?

## Connection pooling on serverless
- Each function invocation = potentially new DB connection. Multiplied by concurrent invocations = ?
- Using a connection pooler (PgBouncer, Neon proxy, Supabase Supavisor)?
- Or stateless options like HTTP-based DB (Neon's HTTP driver, PlanetScale)?

## Edge vs Node decision
- Why this runtime? (locality, bundle size, capability needs)
- Anything that doesn't work in Edge (Node APIs, native modules)?
- Database driver compatible with chosen runtime?

## Cost & quotas
- Function invocations per month projected?
- Bandwidth (egress) cost?
- ISR / on-demand revalidation count?
- Image optimization count?

## Observability
- Function logs flow where? (Vercel logs only, or shipped to Datadog/Logtail?)
- Errors surface to Sentry/equivalent with bolt context?
- Cold start metric visible?

## Webhook / external trigger
- If a webhook triggers a function: HMAC verified? Replay protection?
- Idempotency key from external source?
- Slow webhook → timeout → retry from external → duplicate processing?
