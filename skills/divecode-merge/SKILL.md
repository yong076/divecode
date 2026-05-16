---
name: divecode-merge
description: |
  Merge the bolt PR per profile.pr.merge_strategy (squash | rebase | merge).
  Use after /divecode-pr-watch returns status: green (or after a final fix-loop
  has cleared must-fix). Before /divecode-cleanup.
triggers:
  - divecode merge
  - merge the pr
  - merge bolt
allowed-tools:
  - Bash
  - Read
  - Write
---

# divecode-merge — strategy-aware merge

You are running **divecode-merge**. Merge the bolt's PR per the profile's strategy.

## Iron Laws

1. **Never merge to main/master via non-PR push.** Always go through the PR.
2. **Strategy is profile-driven.** Don't ask which strategy each time.
3. **Verify gates passed** before invoking merge: pr-watch must have returned `green` for the latest poll.
4. **Don't force-merge** past failing required checks unless user explicitly authorized.

## Preamble

```bash
PROJ_DIR="${DIVECODE_PROJECT_DIR:-$PWD}"
PROFILE_FILE="$PROJ_DIR/.divecode/profile.yml"
STRATEGY=$(awk '/^pr:/{found=1;next} found && /^  merge_strategy:/{print $2; exit}' "$PROFILE_FILE" 2>/dev/null)
[ -z "$STRATEGY" ] && STRATEGY=squash

PR=$(grep -E '^url:' "$PROJ_DIR/divecode/push-pr.md" 2>/dev/null | head -1 | grep -oE '/pull/[0-9]+' | grep -oE '[0-9]+')

# Verify latest pr-watch was green
LAST_STATUS=$(grep -E '^status:' "$PROJ_DIR/divecode/pr-watch.md" 2>/dev/null | tail -1 | awk '{print $2}')
[ "$LAST_STATUS" = "green" ] || { echo "✗ pr-watch latest status is '$LAST_STATUS' (must be green)"; exit 1; }

echo "PR:       $PR"
echo "STRATEGY: $STRATEGY"
```

## Workflow

```bash
case "$STRATEGY" in
  squash) gh pr merge "$PR" --squash --delete-branch ;;
  rebase) gh pr merge "$PR" --rebase --delete-branch ;;
  merge)  gh pr merge "$PR" --merge --delete-branch ;;
  *)      echo "unknown merge strategy: $STRATEGY"; exit 1 ;;
esac
```

Output `divecode/merge.md`:
```
# merge.md
strategy:  <s>
merge_sha: <hash>
target:    <branch>
merged_at: <timestamp>
```

## Done criteria
- PR shows MERGED state
- Local branch will be cleaned up in next phase
- `merge.md` written

Suggest `/divecode-cleanup` next.
