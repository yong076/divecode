---
name: divecode-commit
description: |
  Group bolt changes into logical commits per profile.commit_convention. Honors
  style (conventional | freeform) and co_author (include | omit). Use after
  /divecode-fix-loop (or /divecode-review if no must-fix), before /divecode-push-pr.
triggers:
  - divecode commit
  - commit the bolt
allowed-tools:
  - Bash
  - Read
  - Write
  - AskUserQuestion
---

# divecode-commit — convention-aware committing

You are running **divecode-commit**. Group the bolt's changes into logical commits per the profile's convention.

## Iron Laws

1. **One commit per logical unit.** A slice typically = one commit. Tests + production code for the same slice can be one commit OR split (split is preferred for strict).
2. **Convention is profile-driven.** No improvisation.
3. **Stage explicit files, not `git add .`.** Avoid accidentally committing secrets / build artifacts.
4. **Hooks are not bypassed.** If a pre-commit hook fails, fix the underlying issue.

## Preamble

```bash
PROJ_DIR="${DIVECODE_PROJECT_DIR:-$PWD}"
PROFILE_FILE="$PROJ_DIR/.divecode/profile.yml"
STYLE=$(grep -E '^[[:space:]]+style:' "$PROFILE_FILE" 2>/dev/null | head -1 | awk '{print $2}')
COAUTHOR=$(grep -E '^[[:space:]]+co_author:' "$PROFILE_FILE" 2>/dev/null | head -1 | awk '{print $2}')
[ -z "$STYLE" ] && STYLE=conventional
[ -z "$COAUTHOR" ] && COAUTHOR=omit

echo "STYLE:    $STYLE"
echo "COAUTHOR: $COAUTHOR"
git -C "$PROJ_DIR" status --short
```

## Workflow

### Step 1 — Plan the commits
Read `slice-plan.md` and the diff. Propose a commit list:

> "I'll create N commits:
>   1. feat(detect): profile auto-detection + tests
>   2. feat(bolt): bolt creation + state directory
>   ...
> OK?"

### Step 2 — Per commit
- Stage exactly the files for that commit (`git add <files>`, never `git add .`)
- Compose message per style:
  - **conventional**: `<type>(<scope>): <subject>` + optional body
  - **freeform**: a clear human sentence + paragraph if needed
- Apply co-author trailer only if `co_author: include`
- Run `git commit -m "..."` via HEREDOC for multi-line bodies

### Step 3 — Verify
After all commits: `git log <base>..HEAD --oneline` — show the user.

## Output

`divecode/commit.md`:
```
# commit.md
- abc1234 feat(detect): profile auto-detection + tests
- def5678 feat(bolt): bolt creation + state directory
- ...
```

## Done criteria
- All bolt changes committed
- No unintended files staged
- `commit.md` written with hash + subject per commit
