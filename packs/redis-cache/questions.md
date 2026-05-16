# questions — redis-cache

Fire these when the PRD mentions Redis or any KV-style cache.

## TTL & invalidation
- What's the TTL? Why that number specifically?
- Which write paths invalidate this cache? List every one.
- If a write succeeds but cache invalidation fails, what's the recovery?
- Are TTLs jittered? (otherwise simultaneous mass expiry → stampede)

## Cache stampede
- When a hot key expires under load, do N requests all hit origin?
- Single-flight / mutex on cache miss?
- Probabilistic early expiration?
- Fallback if origin is overwhelmed?

## Eviction & memory
- Eviction policy: `allkeys-lru`, `volatile-lru`, `noeviction`, ... ? Pick explicitly.
- What happens to writes when memory is full and policy is `noeviction`? (writes error!)
- Memory budget? Alert threshold?

## Consistency
- Read-your-writes — does this matter? (cache-aside writes through to cache too?)
- Stale read tolerance window?
- Cross-region replication if multi-region?

## Persistence
- RDB snapshot, AOF, both, or neither (pure cache)?
- What's acceptable to lose on instance failure?

## Cluster / sharding
- Single node, primary-replica, or cluster?
- Multi-key operations limited by hash slot?
- Client behavior during failover?

## Connection pool
- Pool size per app instance?
- Pipeline batching used?
- Connection + idle timeouts set?

## Negative caching
- Cache "not found" entries to prevent origin pounding?
- Shorter TTL for negatives?

## Observability
- Cache hit ratio metric exposed?
- Slow-log threshold configured?
- Key cardinality monitored? (memory blowup canary)
