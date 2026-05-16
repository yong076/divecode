# test-ideas — postgres-saas

## Connection pool ceiling
Load test: ramp app instances × pool size until you hit DB max_connections. Assert app degrades (returns 503, queues requests) rather than 500s.

## Migration on representative data
Run every migration against a copy of production-size data in CI. Time the lock duration. Fail CI if it exceeds threshold (e.g., 5s for online migrations).

## N+1 detection
Hook the test suite with a query counter. For each endpoint test, assert query count ≤ expected. Fail if it scales with input.

## Index coverage
For every reported slow query in the last week, write a test asserting EXPLAIN shows index use (not Seq Scan).

## Optimistic concurrency
Two test workers update the same row simultaneously. Assert one succeeds and the other gets the documented conflict error (not a silent overwrite).

## Connection leak under errors
Force every code path that does DB work to also throw an exception. Assert pool size returns to baseline after the test (no leak).
