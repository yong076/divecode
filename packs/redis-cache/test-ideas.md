# test-ideas — redis-cache

Concrete test cases the answers should produce.

## Stampede behavior
- Synthetic load: 1000 concurrent reads on a key that's about to expire. Assert origin sees ≤ 1 (or ≤ small N for single-flight relaxation).

## Eviction under pressure
- Fill Redis to maxmemory + 10%. Assert writes succeed if policy is `allkeys-lru` (oldest evicted) and fail with documented error if `noeviction`.

## TTL jitter
- Insert 100 keys at the same instant with `ttl=300, jitter=30s`. Inspect actual TTLs — should span ~570-630s, not all 600s.

## Invalidation idempotency
- Trigger the same invalidation event twice. Assert no error and that the second call is a no-op.

## Cache-aside read-your-writes
- Write to origin → invalidate cache. Then immediate read should hit origin (cache miss expected). Assert origin lookup happens.

## Negative cache TTL shorter than positive
- Lookup non-existent key. Cache the miss with TTL_NEG. Assert TTL_NEG < TTL_POS.

## Connection pool exhaustion graceful fallback
- Simulate Redis connection refused. Assert app degrades to origin reads (slower but works), not 500s.

## Cluster failover transparency
- Trigger primary failover during sustained load. Assert client retries succeed within timeout window; assert no data loss for committed writes.
