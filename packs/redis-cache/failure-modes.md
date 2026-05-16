# failure-modes — redis-cache

Real production incidents this pack exists to prevent.

## Cache stampede (the canonical one)
A hot key's TTL expires. N concurrent requests miss cache simultaneously. All N hit the origin DB. Origin saturates, latencies spike, more requests pile up. Cascading failure.

**Detection signal**: p99 latency jumps coincide with cache miss rate spikes for specific keys.

## Mass expiry
Many keys written together at startup get TTLs computed at the same moment → all expire within the same second → stampede × N keys.

**Detection signal**: periodic latency bumps matching TTL boundaries.

## noeviction surprise
Memory fills up. Eviction policy is the default `noeviction`. New writes start returning `OOM` errors. Whoever depended on `SET` being best-effort is now broken.

**Detection signal**: sudden surge of `OOM command not allowed when used memory > maxmemory` errors.

## Cache invalidation race
Write to origin succeeds. Cache invalidation gets dropped (network glitch, queue full, etc.). Subsequent reads return stale value. Could be hours before noticed.

**Detection signal**: support tickets about "I updated X but it still shows old value."

## Write-through that isn't
Cache writes acknowledged before origin commits. Origin fails. Cache says A, origin says B. Read returns A; subsequent revalidation gets B. Lost-update class.

**Detection signal**: occasional dropped writes that the application "remembers happened" but origin doesn't have.

## Replication lag visible to user
Primary-replica setup. Write goes to primary. Read immediately goes to replica. Replica hasn't caught up. User sees their own write disappear.

**Detection signal**: "I just changed X and now it's back to the old value" reports.

## Connection exhaustion
App scaled out without scaling Redis connection pool. Each app instance opens N connections. M instances × N > Redis maxclients. New connections start refusing.

**Detection signal**: `ERR max number of clients reached` in app logs.
