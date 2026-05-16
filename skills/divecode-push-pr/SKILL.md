---
name: divecode-push-pr
description: |
  Push the bolt branch and open a PR against profile.pr.target_branch. PR body
  references design.md sections, slice list, verification results, open risks.
  Degrades gracefully when gh CLI is missing (prints push instructions instead).
  Use after /divecode-commit, before /divecode-pr-watch.
triggers:
  - divecode push-pr
  - push and open pr
  - open pr
allowed-tools:
  - Bash
  - Read
  - Write
---

# divecode-push-pr — push + open PR

You are running **divecode-push-pr**. Push the branch and open a PR with a body that references the bolt's artifacts.

## Iron Laws

1. **Never push to main/master directly.** PR-only.
2. **Body is structured.** Reviewers should grasp scope from the body alone.
3. **Degrade gracefully without `gh`.** If missing, print the manual command and exit 0.
4. **Don't force-push** unless the user explicitly asked.

## Preamble

```bash
PROJ_DIR="${DIVECODE_PROJECT_DIR:-$PWD}"
PROFILE_FILE="$PROJ_DIR/.divecode/profile.yml"
TARGET=$(awk '/^pr:/{found=1;next} found && /^  target_branch:/{print $2; exit}' "$PROFILE_FILE" 2>/dev/null)
[ -z "$TARGET" ] && TARGET=main

BRANCH=$(git -C "$PROJ_DIR" branch --show-current)
echo "BRANCH: $BRANCH"
echo "TARGET: $TARGET"

if ! command -v gh >/dev/null 2>&1; then
  echo "✗ gh CLI not found — will print manual push/PR commands"
fi
```

## Workflow

### Step 1 — Push
```bash
git -C "$PROJ_DIR" push -u origin "$BRANCH"
```

### Step 2 — Compose PR body

Read these inputs and synthesize:
- `divecode/design.md` §2 (Spec — goal + in-scope)
- `divecode/slice-plan.md` (slice list — bullet)
- `divecode/final-review.md` (must-fix count + final disposition)
- `divecode/fix-loop.md` if present (rounds + remaining)

Body template:
```markdown
## Summary
<one paragraph from design.md §2 Goal>

## Slices
- 1. <name>
- 2. <name>
...

## Verification
- tests: PASS (N suites)
- gates: <tdd / repo-pattern / etc>
- review: <must-fix N → resolved>

## Open risks
<from design.md §2 Open risks>

🤖 Generated with [divecode](https://github.com/yong076/divecode)
```

### Step 3 — Open PR

If `gh` present:
```bash
gh pr create --base "$TARGET" --title "<bolt title>" --body "$(cat <<'EOF'
<body>
EOF
)"
```

If not:
```
push complete. To open the PR manually:
  gh pr create --base main --title "..." --body "<see divecode/push-pr.md>"
```

### Step 4 — Record
Write `divecode/push-pr.md`:
```
# push-pr.md
url:   <PR URL>
title: <title>
target: <branch>
body_summary: <first 3 lines>
```

## Done criteria
- Branch pushed
- PR opened (or manual command printed if no gh)
- `push-pr.md` written
