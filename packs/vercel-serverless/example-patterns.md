# example-patterns — vercel-serverless

## Move long work to a queue, return fast

```typescript
// Bad — risks 10s timeout
export async function POST(req: Request) {
  await processFile(req);  // takes 30s
  return new Response('ok');
}

// Better — accept, enqueue, ack immediately
export async function POST(req: Request) {
  const body = await req.json();
  await queue.enqueue('process_file', body);
  return new Response('queued', { status: 202 });
}
```

## Cron idempotency via cursor

```typescript
// vercel.json
{ "crons": [{ "path": "/api/cron/sync", "schedule": "*/5 * * * *" }] }

// /api/cron/sync.ts
export async function GET() {
  const cursor = await db.cron_cursor.get('sync');
  const newRows = await source.fetch_since(cursor);
  for (const row of newRows) {
    await db.upsert(row);  // upsert is naturally idempotent
  }
  await db.cron_cursor.set('sync', new Date());
  return new Response('ok');
}
```

## Webhook signature + idempotency

```typescript
export async function POST(req: Request) {
  const sig = req.headers.get('x-webhook-signature');
  if (!verifyHmac(sig, await req.text(), WEBHOOK_SECRET)) {
    return new Response('bad sig', { status: 401 });
  }
  const event = JSON.parse(body);
  // Idempotency: store the event id; reject duplicates
  const inserted = await db.processed_events.upsert(event.id, { ignoreConflict: true });
  if (!inserted) return new Response('duplicate', { status: 200 });
  await handle(event);
  return new Response('ok');
}
```

## HTTP-based DB driver for serverless (Neon)

```typescript
import { neon } from '@neondatabase/serverless';
const sql = neon(process.env.DATABASE_URL!);

// No pool to manage — each query is a single HTTPS round trip.
// Trades a bit of latency for zero connection bookkeeping in serverless.
export async function GET() {
  const rows = await sql`SELECT count(*) FROM orders`;
  return Response.json(rows);
}
```
