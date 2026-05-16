# test-ideas — admin-dashboard

## Load from internal-only traffic
Simulate 10 dashboards × auto-refresh × 24h. Assert backend qps stays within budget. If not, increase refresh interval or add caching.

## Auth on every endpoint
For every dashboard endpoint, automated test: hit it without auth → assert 401/403. Hit it with auth from wrong group → assert 403.

## Destructive action requires confirmation
Test "Delete X" click: first click shows confirm modal. Only second click in the confirm modal actually deletes.

## Audit log written on view
Every dashboard page view writes one audit row (who, when, what). Test this exists.

## Cache freshness shown
If a value comes from a cache, the UI labels it with the cache timestamp. Test that the label is present and accurate.

## Slow query never blocks render
Backend simulates 10s response. Frontend shows skeleton, not a stuck spinner. Recovers when response arrives.
