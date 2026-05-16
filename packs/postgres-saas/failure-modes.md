# failure-modes — postgres-saas

## Connection exhaustion
App scales horizontally. Each instance opens a pool of 20 connections. 10 instances → 200 connections. Postgres max_connections is 100. New requests get "too many connections" errors.

**Detection**: spike in `FATAL: sorry, too many clients already` in app logs.

## Migration lock surprise
A "tiny" `ALTER TABLE ADD COLUMN` on a multi-million-row table acquires an ACCESS EXCLUSIVE lock. Deploy hangs. All reads to that table queue. Site effectively down for the duration.

**Detection**: deploy times out; user-facing reads timing out at the same moment.

## Long transaction holding locks
A background job opens a transaction, calls an external API mid-transaction (takes 30s), then commits. During those 30s, every row it touched is locked. Random user requests hit those rows and queue.

**Detection**: scattered p99 spikes that correlate with the background job's schedule.

## Read replica lag visible to user
Write to primary. Immediate read goes to read replica via load balancer. Replica hasn't replicated yet. User sees their write disappear. They click again. Now you have a duplicate.

**Detection**: "I just clicked X, now it's gone" support tickets.

## N+1 in production with ORMs
ORM lazy-loads associations. Fine in dev with 5 records. Production has 5000 per page. Page render fires 5000 queries.

**Detection**: page latency proportional to result set size, not constant.

## Backup never tested restore
RPO/RTO defined on paper. When disk dies, the backup is from 6 days ago because automation broke silently 6 days ago.

**Detection**: only when you need it. Prevent by routine restore drills.

## Connection leak on error path
Try/finally not closing the connection in some branch. Pool slowly exhausts over hours/days.

**Detection**: very gradual rise in active connections in monitoring; eventual cliff.

## pg_dump in production hours
Backup process holds repeatable-read transaction for hours on a busy database. Vacuum blocked. Table bloat grows.

**Detection**: storage usage growing faster than data volume; vacuum stats show blocked workers.
