# SQL / RDBMS checklist

Surface when Postgres / MySQL / SQLite / any relational DB is mentioned.

## Schema
- [ ] Primary key strategy: auto-increment, UUID v4, UUID v7, ULID, composite? **Why that choice?**
  - auto-inc: leaks order/count; fast indexes
  - UUIDv4: random → poor index locality on writes
  - UUIDv7 / ULID: time-ordered → better
- [ ] Every FK has an index? (otherwise cascading deletes scan entire child table)
- [ ] Composite indexes — column order matters. Most-selective-first? Or query-pattern-first?
- [ ] Partial indexes considered for sparse columns?
- [ ] `text` vs `varchar(n)` — Postgres: no difference; MySQL: huge difference

## Isolation level
- [ ] What isolation level for which transactions? (Read Committed, Repeatable Read, Serializable)
- [ ] Do you understand what anomaly each level allows?
  - Read Committed: non-repeatable reads, phantom reads, lost updates
  - Repeatable Read (PG): no non-repeatable reads, but write skew possible
  - Serializable: full isolation but retries possible
- [ ] Where do you retry on serialization failure? (must be at app level, outside the tx)

## Transaction scope
- [ ] Where does each transaction start and end? **Draw it.**
- [ ] Network calls inside a transaction? (don't — holds locks)
- [ ] Email/notification sends — outside the tx, with outbox pattern?
- [ ] Long-running operations holding locks?

## Lost updates
- [ ] Two users edit the same row — what happens?
  - last-write-wins (silently overwrites)
  - optimistic concurrency (`version` column, fail on conflict)
  - pessimistic (`SELECT ... FOR UPDATE`)
- [ ] If optimistic: how does the UI surface the conflict?

## N+1 and batching
- [ ] Every list query has a JOIN or batch-load for related data? (DataLoader pattern)
- [ ] ORM lazy-loading enabled? (often the silent killer)
- [ ] Eager-load whitelist defined per query?

## Pagination
- [ ] Offset or cursor-based? (offset is O(n) — bad after page ~100)
- [ ] Stable sort key for cursor? (must be unique + indexed)
- [ ] Total count needed? (often very expensive — can it be approximate?)

## Migrations
- [ ] Migration tool? (rails, alembic, sqlx, prisma, ...)
- [ ] Zero-downtime migrations? (no locking ALTERs on big tables — multi-step expand/contract)
- [ ] How long does this migration hold a lock? Tested?
- [ ] Rollback strategy?
- [ ] Backfill of new columns — done in batches, not one huge UPDATE?

## Backup & recovery
- [ ] Backup frequency? Tested restore?
- [ ] PITR (point-in-time recovery)? Window?
- [ ] RPO (data you can afford to lose)? RTO (recovery time)?

## Connection pool
- [ ] Pool size per app instance × number of instances ≤ DB max connections?
- [ ] PgBouncer / RDS Proxy in front for high concurrency?
- [ ] Pool mode: transaction vs session? (transaction pooling breaks LISTEN/NOTIFY, prepared statements)

## Query performance
- [ ] EXPLAIN ANALYZE run on every query that hits >10k rows?
- [ ] Slow query log threshold set?
- [ ] Query timeout set per request?

## Multi-tenancy (if applicable)
- [ ] Tenant isolation: shared schema + tenant_id, schema per tenant, or DB per tenant?
- [ ] Row-level security policies for shared schema?
- [ ] Index on tenant_id on every shared table?
