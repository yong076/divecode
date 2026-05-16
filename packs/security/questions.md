# Security checklist

Surface for any feature touching auth, user input, external services, or sensitive data.

## Authentication
- [ ] Identity provider? (own DB, OAuth, SSO, magic link, passkey?)
- [ ] Session storage — cookie, JWT, server-side session?
- [ ] Session TTL and refresh strategy?
- [ ] Multi-device session invalidation? (logout-everywhere)
- [ ] Account recovery — secure but not too painful?

## Authorization (separate from authn)
- [ ] Authz model: RBAC, ABAC, ReBAC, custom?
- [ ] Where is authz enforced? **Every endpoint?** Every query?
- [ ] Row-level vs object-level authz?
- [ ] IDOR (insecure direct object reference) — can user A read user B's resource by guessing an ID? **Tested?**

## Input validation
- [ ] Every input has a schema (Zod, Pydantic, etc.)?
- [ ] Length / size limits on every string and array?
- [ ] File upload — type checked? Magic bytes verified? Size limited? Scanned?
- [ ] SSRF prevention on any URL-fetching endpoint?

## Output / encoding
- [ ] Auto-escaping in templates (React/Vue handle by default)?
- [ ] Anywhere using `dangerouslySetInnerHTML` / `v-html` / `innerHTML`?
- [ ] User-controlled URL in `<a href>` — javascript: scheme blocked?
- [ ] CSP header configured?

## SQL injection
- [ ] All queries parameterized? (no string concat)
- [ ] Any dynamic SQL (sort column, table name from user)? Whitelisted?

## Secrets
- [ ] No secrets in code? (verified with scanner)
- [ ] Secrets manager? (AWS SM, Vault, Doppler, ...)
- [ ] Rotation policy?
- [ ] Local dev secrets separate from prod?
- [ ] Git history scanned for leaked secrets?

## Crypto
- [ ] Passwords: bcrypt / argon2 / scrypt — never MD5 / SHA1 / unsalted SHA256
- [ ] Random tokens from cryptographic RNG?
- [ ] TLS everywhere — including internal service-to-service?
- [ ] Cert renewal automated?

## Rate limiting / abuse
- [ ] Rate limit on auth endpoints (login, signup, password reset)?
- [ ] Rate limit on expensive endpoints?
- [ ] Per-user, per-IP, or both?
- [ ] CAPTCHA / proof of work for high-abuse endpoints?

## PII / sensitive data
- [ ] PII inventory — what fields are PII?
- [ ] Encryption at rest for PII columns?
- [ ] PII in logs? **Audit log statements.**
- [ ] PII in error messages / stack traces shown to users?
- [ ] Data retention policy?
- [ ] Right-to-delete (GDPR) — implementable?

## Dependencies
- [ ] SCA / dependency vulnerability scanner in CI?
- [ ] Update cadence?
- [ ] Lockfile committed?
- [ ] Build reproducible?

## Headers
- [ ] HSTS?
- [ ] CSP?
- [ ] X-Frame-Options / frame-ancestors?
- [ ] X-Content-Type-Options: nosniff?
- [ ] Referrer-Policy?

## Audit logs
- [ ] Sensitive actions logged? (auth events, permission changes, data export)
- [ ] Audit log tamper-evident? (append-only, signed)
- [ ] Retention sufficient for compliance?

## Cross-cutting
- [ ] CSRF protection on state-changing requests?
- [ ] CORS — explicit allowlist, not `*`?
- [ ] Open redirects prevented?
- [ ] Subdomain takeover risk reviewed?

## Compliance regimes (if applicable)
- [ ] GDPR — DPA, DSAR flow, consent records
- [ ] HIPAA — BAA, audit logs, access controls
- [ ] PCI — never store card numbers, tokenize
- [ ] SOC2 — change management, access reviews
