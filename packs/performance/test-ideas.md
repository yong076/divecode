# test-ideas — performance

## N+1 query count guard
Wrap test endpoints with a query counter. For each list endpoint, assert query count ≤ small_constant. Fail if it scales with input.

## Bundle size budget in CI
Build step outputs bundle sizes. CI compares to baseline; fail the build if total or critical-route bundle grew by > N KB without explicit waiver in PR.

## p99 latency contract per endpoint
Per-route latency budget declared in code/config. Synthetic load test at ≥ 2× projected peak. Fail CI if p99 exceeds budget.

## Cold start envelope
Cold-invoke each serverless function in a fresh deploy. Assert cold start < N seconds for user-facing routes.

## Web Vitals real-user monitoring
Send LCP / INP / CLS to your analytics. Define thresholds (LCP < 2.5s, INP < 200ms, CLS < 0.1). Alert when 75th percentile of real users crosses red.

## Cache hit ratio assertion
Run a representative workload. Assert cache hit ratio ≥ planned_minimum (e.g., 80%). If lower, key cardinality or TTL is misconfigured.

## Pagination smoke at scale
Seed test DB with 100k rows. Assert page 1, page 100, page 1000 all return within budget.
