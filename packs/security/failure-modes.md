# failure-modes — security

## IDOR (insecure direct object reference)
Endpoint reads `id` from URL and returns the resource without checking the caller owns it. Anyone who guesses an id can read anyone's data.

**Detection signal**: only by audit or breach. Prevent by enforcing authz on every read, not just the landing page.

## Authz at page level, not API level
The /admin page checks auth. The /api/admin/* endpoints don't. Anyone who reverse-engineers the API can pull data without ever visiting the page.

**Detection signal**: same as IDOR — by audit.

## Secrets in source / git history
`API_KEY=sk_live_…` committed once, removed in a later commit, still in `git log -p`. Public repo? Compromised forever.

**Detection signal**: secret scanners (gitleaks, trufflehog) catch it; or rotation request from the vendor.

## PII in logs
`logger.info("user logged in", user)` serializes the whole user into structured logs. Email, phone, address. Logs aggregated to a third-party. PII everywhere.

**Detection signal**: audit log statements; check what your logger serializes by default.

## CSRF on state-changing endpoints
POST /transfer-money relies on session cookie. Attacker hosts a page that submits a hidden form while the user is logged in.

**Detection signal**: penetration test or unexplained user-initiated actions.

## Password hashed with MD5 / SHA1
Looks hashed. Isn't really. GPU farm cracks all passwords in hours.

**Detection signal**: only after breach. Prevent with bcrypt / argon2 / scrypt.

## Open redirect
`/login?next=/dashboard` is fine. `/login?next=https://evil.com` redirects after login, used in phishing chains.

**Detection signal**: phishing reports referencing your domain.

## Rate limiting only on /login
Login is protected, but password reset accepts unlimited attempts. Attacker enumerates emails or guesses reset tokens.

**Detection signal**: spike in reset attempts; user reports of unsolicited reset emails.

## CORS = *
Wildcard CORS on an authenticated API. Any site can call your API with the user's cookies.

**Detection signal**: only via audit. Check Access-Control-Allow-Origin in production responses.
