# example-patterns — security

## Authz at the data layer, not the controller

```typescript
// Bad: controller checks; SQL doesn't
async function getOrder(req) {
  if (!req.user) return 401;
  return db.orders.findById(req.params.id);  // any id works
}

// Good: tenant scope baked into the query
async function getOrder(req) {
  if (!req.user) return 401;
  return db.orders.findOne({ id: req.params.id, ownerId: req.user.id });
}
```

## Bcrypt + cost factor

```typescript
import bcrypt from 'bcrypt';
const COST = 12;  // ~250ms per hash on modern hardware; review yearly

async function hashPassword(plain: string) {
  return bcrypt.hash(plain, COST);
}

async function verifyPassword(plain: string, hash: string) {
  return bcrypt.compare(plain, hash);  // constant-time
}
```

## Secrets in env, not in code

```typescript
// .env (gitignored)
STRIPE_SECRET_KEY=sk_live_…
DATABASE_URL=postgres://…

// access
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!);
```

Production secrets come from a secret manager (AWS SM, Vault, Doppler, Vercel envs), not committed `.env`.

## Open redirect prevention

```typescript
const ALLOWED_REDIRECTS = /^\/(?!\/)/;  // must start with single slash

function safeRedirect(next: string | undefined) {
  if (!next || !ALLOWED_REDIRECTS.test(next)) return '/';
  return next;
}
```

## CSP / HSTS / standard headers

```typescript
const cspHeader = `
  default-src 'self';
  script-src 'self' 'nonce-${nonce}' https://cdn.trusted.com;
  style-src 'self' 'unsafe-inline';
  img-src 'self' blob: data:;
  connect-src 'self' https://api.yours.com;
  frame-ancestors 'none';
`.replace(/\n\s+/g, ' ').trim();

response.headers.set('Content-Security-Policy', cspHeader);
response.headers.set('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
response.headers.set('X-Content-Type-Options', 'nosniff');
response.headers.set('Referrer-Policy', 'strict-origin-when-cross-origin');
```

## Rate limit on auth endpoints

```typescript
import rateLimit from 'express-rate-limit';

const authLimiter = rateLimit({
  windowMs: 15 * 60_000,
  max: 5,
  message: 'Too many attempts — try again in 15 minutes',
});

app.post('/login', authLimiter, loginHandler);
app.post('/password-reset', authLimiter, resetHandler);
```
