# questions — postgres-saas

## Connection management
- What's the max-connections ceiling on the Postgres service? (Neon free tier: ~20; Supabase: depends; RDS: depends on instance)
- App instances × pool-size-per-instance ≤ ceiling?
- Using PgBouncer / RDS Proxy / Neon's built-in pooler?
- Pool mode: session, transaction, or statement? (Transaction pooling breaks LISTEN/NOTIFY, prepared statements)

## Migrations
- Which migration tool? (Prisma, Drizzle, Alembic, sqlx, ...)
- How long does the slowest planned migration lock the table?
- Zero-downtime strategy? (expand → backfill → contract pattern?)
- Rollback plan for each migration?
- Migrations run in CI, deploy pipeline, or manually?

## Indexes & queries
- Every FK has an index? (otherwise cascading deletes scan the child table)
- Composite index column order matches the queries that use them?
- EXPLAIN ANALYZE run on queries hitting > 10k rows?
- Slow query log threshold configured? Where do slow queries surface?

## Isolation & locking
- What isolation level per transaction type? (Read Committed default; Repeatable Read for reports; Serializable when you must)
- Where do you retry on serialization failure?
- Any transaction holding row locks across a network call?
- Lock acquisition order consistent (deadlock prevention)?

## Backup & recovery
- Backup frequency? (Neon: PITR window? Supabase: daily snapshots?)
- Tested restore? When?
- RPO / RTO defined?

## Multi-tenancy (if SaaS)
- Tenant isolation: shared schema + tenant_id, schema-per-tenant, or DB-per-tenant?
- Row-level security policies if shared?
- Every shared table has an index on tenant_id?

## Schema evolution
- Adding a NOT NULL column to a big table — strategy? (default + backfill in batches)
- Renaming a column without breaking the app — plan?
- Soft-delete vs hard-delete decision per table?

## Cost
- Estimated read/write volume per month?
- Storage growth projection?
- Egress costs to other regions / clients?
