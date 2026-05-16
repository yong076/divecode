# example-patterns — redis-cache

Concrete reference snippets. Not prescriptive — just "this is what good looks like."

## Jittered TTL

```python
import random

JITTER_RANGE = 0.1  # ±10%

def cache_set(key: str, value: bytes, ttl_seconds: int) -> None:
    actual_ttl = int(ttl_seconds * random.uniform(1 - JITTER_RANGE, 1 + JITTER_RANGE))
    redis.setex(key, actual_ttl, value)
```

## Single-flight on cache miss

```python
import threading

_locks: dict[str, threading.Lock] = {}
_locks_guard = threading.Lock()

def get_with_singleflight(key: str, fetch_origin):
    cached = redis.get(key)
    if cached is not None:
        return cached
    with _locks_guard:
        lock = _locks.setdefault(key, threading.Lock())
    with lock:
        # Re-check: another thread may have populated it while we waited
        cached = redis.get(key)
        if cached is not None:
            return cached
        fresh = fetch_origin()
        redis.setex(key, 300, fresh)
        return fresh
```

## Probabilistic early refresh

```python
import math, random, time

def get_with_early_refresh(key: str, fetch_origin):
    """Returns cached value; with rising probability as TTL approaches 0,
    refreshes from origin to prevent stampede at expiry."""
    val, ttl_remaining = redis.get_with_ttl(key)
    if val is None:
        val = fetch_origin()
        redis.setex(key, 300, val)
        return val
    # Probabilistic early expiration (Vasiliki et al.)
    beta = 1.0
    if random.random() < math.exp(-beta * ttl_remaining / 60):
        new_val = fetch_origin()
        redis.setex(key, 300, new_val)
        return new_val
    return val
```

## Eviction policy declared explicitly in IaC

```hcl
# Terraform — Upstash Redis
resource "upstash_redis_database" "cache" {
  database_name = "app-cache"
  region        = "us-east-1"
  eviction      = "allkeys-lru"   # NOT the default; declare on purpose
}
```

## Negative caching with shorter TTL

```python
TTL_POSITIVE = 300  # 5 min for real values
TTL_NEGATIVE = 30   # 30s for "not found" — lets new resources appear faster

def lookup(id_: str):
    cached = redis.get(f"item:{id_}")
    if cached == b"__NOT_FOUND__":
        return None
    if cached is not None:
        return decode(cached)
    item = db.find(id_)
    if item is None:
        redis.setex(f"item:{id_}", TTL_NEGATIVE, b"__NOT_FOUND__")
        return None
    redis.setex(f"item:{id_}", TTL_POSITIVE, encode(item))
    return item
```
