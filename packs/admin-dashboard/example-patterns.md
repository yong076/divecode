# example-patterns — admin-dashboard

## Backoff on auto-refresh

```javascript
// Auto-refresh with exponential backoff when the tab is hidden
let interval = 5000;  // 5s when visible
let timer;

function poll() {
  fetch('/admin/stats').then(render);
  timer = setTimeout(poll, document.hidden ? Math.min(interval * 5, 60000) : interval);
}

document.addEventListener('visibilitychange', () => {
  clearTimeout(timer);
  poll();
});

poll();
```

## Auth middleware (every endpoint)

```typescript
// middleware.ts
export const config = { matcher: ['/admin/:path*', '/api/admin/:path*'] };

export async function middleware(req: NextRequest) {
  const session = await getSession(req);
  if (!session) return new Response('unauth', { status: 401 });
  if (!OPS_TEAM.includes(session.user.email)) {
    audit('access_denied', { email: session.user.email, path: req.url });
    return new Response('forbidden', { status: 403 });
  }
  audit('access', { email: session.user.email, path: req.url });
}
```

## Stale-while-revalidate cache labels

```jsx
<MetricCard
  label="Active users (24h)"
  value={data.value}
  freshAt={data.computed_at}
  hint={isStale(data.computed_at) ? `from ${ago(data.computed_at)} — refreshing…` : null}
/>
```

## Destructive action confirmation

```jsx
const [confirming, setConfirming] = useState(false);
return confirming ? (
  <ConfirmRow
    onCancel={() => setConfirming(false)}
    onConfirm={async () => { await deleteUser(id); audit('delete_user', { id }); }}
    warning="This will delete all data for this user. Cannot be undone for 7 days."
  />
) : (
  <button onClick={() => setConfirming(true)}>Delete user</button>
);
```
