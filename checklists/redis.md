# Redis / Caching checklist

Surface these questions whenever caching, Redis, or any KV store is mentioned. Each item is a place where production systems silently break.

## TTL & invalidation
- [ ] What's the TTL? **Why that number?** ("forever" and "1 hour" are both answers; "I didn't think about it" is not)
- [ ] What write paths invalidate this cache? **List every one.**
- [ ] If a write happens to the DB but cache invalidation fails, what's the recovery?
- [ ] Are TTLs jittered? (otherwise mass simultaneous expiry → cache stampede)

## Cache stampede
- [ ] When a hot key expires under load, do N requests all hit the origin? (single-flight? lock? early refresh?)
- [ ] Probabilistic early expiration considered?
- [ ] What's the fallback if the origin is overwhelmed by stampede?

## Eviction
- [ ] Eviction policy? (`allkeys-lru`, `volatile-lru`, `noeviction`, ...) **Pick one explicitly.**
- [ ] What happens to writes when memory is full and policy is `noeviction`? (errors!)
- [ ] Memory budget? Alert threshold?

## Consistency
- [ ] Read-your-writes — does this matter for this cache? (cache-aside writes through to cache too?)
- [ ] Stale read tolerance window?
- [ ] Cross-region replication? (Redis enterprise / ElastiCache global)

## Persistence
- [ ] RDB snapshot + AOF? Just AOF? Neither (pure cache)?
- [ ] What's lost on instance failure? (acceptable?)
- [ ] Restore time from snapshot?

## Cluster / sharding
- [ ] Single node, primary-replica, or cluster?
- [ ] If cluster: key hash slot considerations? Multi-key operations limited?
- [ ] Failover behavior — what does the client see during failover?

## Connection pool
- [ ] Connection pool size per app instance?
- [ ] Pipeline batching used? (huge perf difference)
- [ ] Connection timeout? Idle timeout?

## Negative caching
- [ ] If a key doesn't exist in origin, do we cache the "not found"? (prevents origin pounding)
- [ ] TTL for negative entries (usually shorter than positive)

## Observability
- [ ] Cache hit ratio metric exposed?
- [ ] Slow-log threshold configured?
- [ ] Key cardinality monitored? (memory blowup signal)
