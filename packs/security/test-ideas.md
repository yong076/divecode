# test-ideas — security

## IDOR test per endpoint
For every resource endpoint, automated test: as user A, fetch user B's resource by id. Assert 403/404, not 200.

## Authz on every API endpoint
Scan all routes. For each, automated test: hit it without auth → assert 401. Hit it with wrong role → assert 403.

## CSRF protection on POST/PUT/DELETE
For every state-changing endpoint, send a request without CSRF token (or with wrong token). Assert rejection.

## Secret scan in CI
Run gitleaks or trufflehog as a CI step. Fail the build on any finding.

## PII in log assertion
In tests, after triggering each log statement, scan log output for PII patterns (emails, phone). Assert none present.

## Rate limit on all sensitive endpoints
List of sensitive endpoints (login, signup, password reset, OTP, payment). Each has a test that fires N+1 requests and asserts the N+1th is rate-limited.

## CSP / HSTS / security headers
Automated test against every response: CSP present, HSTS present, X-Content-Type-Options: nosniff, Referrer-Policy set.

## Password hash algorithm contract
Unit test asserts password storage uses bcrypt/argon2/scrypt (check hash format). Fail if MD5/SHA1/unsalted-SHA256.

## Open redirect smoke
For every redirect endpoint, test that arbitrary external URLs in the `next` parameter are rejected.
