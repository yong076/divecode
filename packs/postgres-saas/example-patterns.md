# example-patterns — postgres-saas

## Zero-downtime add NOT NULL column

```sql
-- Step 1: add nullable with default
ALTER TABLE orders ADD COLUMN status TEXT;

-- Step 2: backfill in batches (separate deployment / job)
UPDATE orders SET status = 'pending' WHERE status IS NULL AND id BETWEEN 1 AND 10000;
-- ... repeat in batches ...

-- Step 3: enforce NOT NULL (separate deployment after backfill verified)
ALTER TABLE orders ALTER COLUMN status SET NOT NULL;
ALTER TABLE orders ALTER COLUMN status SET DEFAULT 'pending';
```

## Connection pool sizing rule

```
pool_size_per_instance × max_concurrent_instances + admin_overhead
  ≤ postgres.max_connections × 0.8
```

Reserve 20% for migrations, monitoring, ad-hoc psql sessions.

## Optimistic concurrency pattern

```sql
-- Schema
ALTER TABLE orders ADD COLUMN version INTEGER NOT NULL DEFAULT 0;

-- Update
UPDATE orders
SET status = $1, version = version + 1
WHERE id = $2 AND version = $3;  -- $3 is the version client read

-- If 0 rows affected, raise a conflict; let app retry or surface to user.
```

## Slow query alert (Neon / generic Postgres)

```sql
ALTER SYSTEM SET log_min_duration_statement = '500ms';
SELECT pg_reload_conf();
-- pipe pg log into alerting system; threshold on count of slow queries per minute
```
