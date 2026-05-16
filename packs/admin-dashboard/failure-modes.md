# failure-modes — admin-dashboard

## Auto-refresh DDoS-ing your own backend
Dashboard auto-refreshes every 5 seconds. 10 ops team members keep it open all day. 10 × 12 reqs/min × 8 endpoints = 960 reqs/min from internal traffic alone — bigger than your real user traffic on quiet days.

**Detection**: backend traffic disproportionately from internal IPs/auth.

## Heavy query on every page load
The dashboard's "active users last 24h" runs `COUNT(DISTINCT user_id)` on a 50M-row table every visit. Page takes 12s. Ops gives up and refreshes.

**Detection**: p99 on dashboard endpoints way above user-facing endpoints.

## Auth gap on async endpoints
Page is gated. The JSON endpoints feeding it are not. Anyone who knows the URL pattern can pull data.

**Detection**: only via security audit or breach. Prevent by reviewing every API endpoint.

## Destructive action without undo
"Delete user" button. Misclick. User's data gone. Cascades. Sales gets called.

**Detection**: support tickets about "I clicked the wrong thing."

## Stale data masquerading as live
Dashboard shows "as of just now" but the underlying cache is 10 minutes stale. Ops makes decisions on wrong data.

**Detection**: ops decisions retroactively wrong; ask them what time they thought the data was from.

## PII screenshot during incident
Ops takes a screenshot to share in Slack. Includes user emails. Shared in a public channel. Compliance event.

**Detection**: rare but expensive. Prevent by minimizing PII shown.

## Polling × tabs × tabs
Single user has dashboard open in 5 tabs. Each tab polls. 5× load from one user. They never close the old tabs.

**Detection**: per-user request counts disproportionate to active users.

## Dashboard latency masks real problem
Dashboard latency is normal but user-facing API is degraded. Ops looking at dashboard doesn't notice. Time-to-detect for user incidents > dashboard refresh cycle.

**Detection**: incidents reported by users before ops noticed.
