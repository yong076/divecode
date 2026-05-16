---
name: divecode-pr-watch
description: |
  Watch a PR — auto-respond to comments and CI failures. Uses bin/divecode-pr-watch
  which polls via gh and emits a routing decision (status + route). 6-status / 7-route
  routing per agent-flow: green→merge, has_comments→fix-loop, ci_failed→fix-loop,
  pending→block, closed→block, merged→cleanup, error→block. Use after /divecode-push-pr,
  before /divecode-merge.
triggers:
  - divecode pr-watch
  - watch pr
  - poll pr
allowed-tools:
  - Bash
  - Read
  - Write
---

# divecode-pr-watch — status-driven routing

You are running **divecode-pr-watch**. Read the PR's live status, decide the next route per agent-flow's 6-status contract.

## Iron Laws

1. **Status is computed, not assumed.** Always actually fetch the PR.
2. **One status → one route.** No "maybe try X then Y" — the routing table is deterministic.
3. **Block ≠ fail.** Pending CI is not a failure; just don't merge yet.
4. **Closed (not merged) requires user input.** Never auto-cleanup a closed-without-merge PR.

## Preamble

```bash
PROJ_DIR="${DIVECODE_PROJECT_DIR:-$PWD}"
DIVECODE_HOME="${DIVECODE_HOME:-$HOME/.divecode}"
[ -x "$DIVECODE_HOME/bin/divecode-pr-watch" ] || DIVECODE_HOME="$HOME/Trappist/divecode"

# Find PR number from push-pr.md
PR=$(grep -E '^url:' "$PROJ_DIR/divecode/push-pr.md" 2>/dev/null | head -1 | grep -oE '/pull/[0-9]+' | grep -oE '[0-9]+')
[ -z "$PR" ] && { echo "could not find PR in divecode/push-pr.md"; exit 1; }
echo "PR: $PR"
```

## Workflow

### Step 1 — Fetch + route
```bash
bash "$DIVECODE_HOME/bin/divecode-pr-watch" "$PR" > "$PROJ_DIR/divecode/pr-watch.md"
cat "$PROJ_DIR/divecode/pr-watch.md"
```

Routing table (matches agent-flow exactly):

| status | route | action |
|---|---|---|
| `green` | `merge` | invoke `/divecode-merge` |
| `has_comments` | `fix-loop` | invoke `/divecode-fix-loop` with PR comments converted into must-fix items |
| `ci_failed` | `fix-loop` | invoke `/divecode-fix-loop`; reproduce the failure locally, fix, push |
| `pending` | `block` | sleep / wait — re-invoke pr-watch after ~5min |
| `closed` (not merged) | `block` | ask user before proceeding |
| `merged` | `cleanup` | invoke `/divecode-cleanup` |
| `error` | `block` | surface error; do not retry until user input |

### Step 2 — Branch per route

Per the table. For `pending`, suggest the user re-invoke later or set a timer.

### Step 3 — Append round entry to pr-watch.md

Each poll/action is recorded:
```
## Round <N> — <date>
status: <s>
route:  <r>
action: <what was done>
```

## Done criteria
- `pr-watch.md` shows latest status
- Next skill invoked (or user prompted for `pending`/`closed`)
