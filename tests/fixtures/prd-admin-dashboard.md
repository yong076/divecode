# PRD: Internal Admin Dashboard

We need a small internal admin dashboard for the ops team.

## Requirements
- Show live counts of agent activity per provider (codex, claude, gemini)
- Pull aggregate stats from our Neon Postgres database
- Cache the heavier queries in Upstash Redis with a 5-minute TTL
- A Vercel cron job warms the cache every 5 minutes
- The dashboard auto-refreshes every 10 seconds in the browser
- Auth via existing GitHub SSO
- Restricted to ops@company.com members

## Scope
Read-only. No writes to provider data from this UI.

## Out of scope
Mobile. Cross-tenant analytics. Anything billing-related.
