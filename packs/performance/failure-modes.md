# failure-modes — performance

## N+1 from ORM lazy-loading
Dev fine, prod terrible. Each row of a list triggers an extra query. 1000 rows = 1001 queries. Page p99 scales linearly with input.

**Detection signal**: endpoint latency proportional to result set size; DB QPS spikes on list endpoints.

## Waterfall API calls in render path
Each render triggers serial fetches: getUser → getProfile → getPreferences → getSubscription. Total latency = sum, not max. Page TTFB 800ms when it could be 200.

**Detection signal**: trace waterfall shows sequential spans where parallel was possible.

## JS bundle bloat from one stray import
Someone imports `lodash` (entire package) for `_.debounce`. Bundle grows 70KB. LCP regresses for all users.

**Detection signal**: bundle size monotonically growing; LCP regression after PR landing.

## Cold start hidden by warm traffic
Average latency fine. p99 has periodic spikes — users hitting cold serverless functions at low-traffic times.

**Detection signal**: p99 spikes correlate with low-QPS valleys; cold-start metric > 0.

## Pagination = offset = O(n)
LIMIT 50 OFFSET 100000 on Postgres scans 100050 rows. Page 2000 takes seconds.

**Detection signal**: latency increases linearly with page number.

## Cache hit ratio low because key cardinality high
"Cache" with per-request keys (timestamp, user-specific in key) has miss rate ~100%. Origin sees full traffic; cache is overhead.

**Detection signal**: cache hit ratio ≤ 10% on what was supposed to be a hot cache.

## Hot path allocation in tight loop
Inner loop allocates new objects per iteration. GC dominates CPU at scale. Profile shows GC > app.

**Detection signal**: CPU doesn't track request rate linearly; GC pause times in tail latency.

## No load test, only "works in dev"
Ship → real traffic → discover the load curve. Often at the worst possible time.

**Detection signal**: discovery of capacity ceiling correlates with feature launch dates.
