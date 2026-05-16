---
name: divecode-worktree
description: |
  Create the working branch (and optionally a git worktree) for the current bolt.
  Honors profile.branching: naming.prefix, slug_style, slug_source, max_slug_length,
  worktree (required | optional | never). Default fallback: feature/<kebab-summary>.
  Refuses to reuse manual namespaces (fix/, claude/) — those are out of divecode scope.
  Use after /divecode-slice-plan, before /divecode-implement.
triggers:
  - divecode worktree
  - create worktree
  - branch for bolt
allowed-tools:
  - Bash
  - Read
  - Write
  - AskUserQuestion
---

# divecode-worktree — branch + worktree

You are running **divecode-worktree**. Create the branch and (optionally) a git worktree per the bolt's profile.

## Iron Laws

1. **Branch name follows profile convention.** No improvisation.
2. **Worktree creation is profile-driven**, not user-asked unless `optional` and user requested.
3. **Refuse to reuse outside-scope prefixes.** `fix/*`, `claude/*`, etc. are manual namespaces — divecode never touches them.
4. **Abort on name collision.** Don't auto-suffix; ask the user.

## Preamble

```bash
PROJ_DIR="${DIVECODE_PROJECT_DIR:-$PWD}"
DIVECODE_HOME="${DIVECODE_HOME:-$HOME/.divecode}"
[ -x "$DIVECODE_HOME/bin/divecode-branch-slug" ] || DIVECODE_HOME="$HOME/Trappist/divecode"

PROFILE_FILE="$PROJ_DIR/.divecode/profile.yml"
PREFIX=$(grep -E '^[[:space:]]+prefix:' "$PROFILE_FILE" 2>/dev/null | head -1 | sed -E 's/.*"([^"]+)".*/\1/')
[ -z "$PREFIX" ] && PREFIX="feature/"
WORKTREE_MODE=$(grep -E '^[[:space:]]+worktree:' "$PROFILE_FILE" 2>/dev/null | head -1 | awk '{print $2}')
[ -z "$WORKTREE_MODE" ] && WORKTREE_MODE="optional"
MAX_LEN=$(grep -E '^[[:space:]]+max_slug_length:' "$PROFILE_FILE" 2>/dev/null | head -1 | awk '{print $2}')
[ -z "$MAX_LEN" ] && MAX_LEN=50

echo "PREFIX:        $PREFIX"
echo "WORKTREE_MODE: $WORKTREE_MODE"
echo "MAX_SLUG_LEN:  $MAX_LEN"
```

## Workflow

### Step 1 — Derive slug from feature title
Ask the user for a short feature title (one sentence) if not implied by the bolt. Then:

```bash
SLUG=$(bash "$DIVECODE_HOME/bin/divecode-branch-slug" "$TITLE" "$MAX_LEN")
BRANCH="${PREFIX}${SLUG}"
echo "BRANCH: $BRANCH"
```

### Step 2 — Validate
- Reject if `$BRANCH` matches `^(fix|claude|hotfix|chore)/`. Tell the user: "that namespace is outside divecode scope; pick a feature-style title."
- Reject if `git rev-parse --verify "$BRANCH"` succeeds (branch exists) — ask the user whether to resume, rename, or abort.

### Step 3 — Create branch + (optional) worktree

```bash
case "$WORKTREE_MODE" in
  required)
    WT_DIR="$(dirname "$PROJ_DIR")/.worktrees/$SLUG"
    git -C "$PROJ_DIR" worktree add -b "$BRANCH" "$WT_DIR"
    echo "WORKTREE: $WT_DIR"
    ;;
  optional)
    # Ask the user via AskUserQuestion: branch only, or branch + worktree?
    git -C "$PROJ_DIR" checkout -b "$BRANCH"
    ;;
  never)
    git -C "$PROJ_DIR" checkout -b "$BRANCH"
    ;;
esac
```

### Step 4 — Write worktree.md artifact

```
# worktree.md
branch:        <BRANCH>
base:          <current main/release>
worktree_path: <path or "no worktree">
profile:       <kind>
created_at:    <timestamp>
```

Save to `divecode/worktree.md` so subsequent phases know where to commit.

## Done criteria

- Branch created and checked out (or worktree created and entered)
- `divecode/worktree.md` written
- No collision with existing branches

Suggest `/divecode-implement` next.
