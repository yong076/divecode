# questions — admin-dashboard

## Auth & access
- Who can see this dashboard? (specific emails, SSO group, OAuth org membership?)
- How is access enforced — on every request, on every API endpoint, or just on the landing page?
- Audit log for who viewed what? Required for compliance?
- Read-only or can take destructive actions? (delete user, refund, etc.)
- If destructive: confirmation step? Undo window? Two-person rule?

## Refresh & load
- How does the page stay fresh? (manual refresh / auto-refresh / WebSocket push)
- If auto-refresh: every how many seconds? Single user × N seconds × all open tabs × all team members = qps on backend. Calculated?
- What happens when the backing query is slow? (skeleton, stale-while-revalidate, hard error)
- Cached queries? TTL? (see redis-cache pack if applicable)

## Heavy queries
- Most expensive query on this page? EXPLAIN ANALYZE result?
- What's the page render time at 10× current data volume?
- Pagination on lists? Cursor or offset?

## Real-time vs scheduled
- Live counters: compute on every request, or background-aggregate every N minutes?
- If background: who orchestrates the schedule? (Vercel cron, Sidekiq, cloud scheduler) — see vercel-serverless / payments packs as applicable.

## Sensitive data exposure
- PII shown? Email, phone, real names? Justified for the use case?
- Tokens / secrets visible? (never)
- Screenshots-for-support workflow — does it leak PII?

## Error visibility
- Error tracking integrated? Linked from dashboard rows so ops can jump to Sentry/Rollbar/etc?
- Alerts when ops sees an error too late?

## Mobile / responsive
- Does anyone access this from phone (during incident response)? If yes, responsive design or separate mobile view?
