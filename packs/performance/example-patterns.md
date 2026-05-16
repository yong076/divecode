# example-patterns — performance

## DataLoader batches N+1 away

```typescript
import DataLoader from 'dataloader';

const userLoader = new DataLoader<string, User>(async (ids) => {
  const rows = await db.users.findMany({ where: { id: { in: [...ids] } } });
  return ids.map(id => rows.find(r => r.id === id)!);
});

// Caller looks 1-by-1 but actually batches per tick
const users = await Promise.all(orders.map(o => userLoader.load(o.userId)));
```

## Cursor pagination instead of offset

```sql
-- offset: O(n) — bad after page ~100
SELECT * FROM orders ORDER BY id LIMIT 50 OFFSET 100000;

-- cursor: O(1) regardless of how deep
SELECT * FROM orders WHERE id > $last_seen_id ORDER BY id LIMIT 50;
```

## Bundle budget enforcement

```json
// package.json
{
  "bundlesize": [
    { "path": "./dist/main.*.js", "maxSize": "150 KB" },
    { "path": "./dist/admin.*.js", "maxSize": "80 KB" }
  ]
}
```

CI runs `bundlesize` after build; fails PR if any chunk exceeds budget.

## Parallel fetches in render path

```typescript
// Bad — waterfall: 200ms + 150ms + 100ms = 450ms
const user = await getUser(id);
const profile = await getProfile(user.profileId);
const subs = await getSubs(user.id);

// Good — parallel: max(200, 150, 100) = 200ms
const [user, profile, subs] = await Promise.all([
  getUser(id),
  getProfile(profileId),
  getSubs(userId),
]);
```

## Lighthouse CI per PR

```yaml
# .github/workflows/lhci.yml
- run: npx @lhci/cli@latest autorun --upload.target=temporary-public-storage
  env:
    LHCI_BUILD_CONTEXT__CURRENT_BRANCH: ${{ github.head_ref }}
```

Posts LCP / INP / CLS deltas vs main on the PR. Red blocks merge.
