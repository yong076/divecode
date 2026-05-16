---
name: divecode-cleanup
description: |
  Final phase of the bolt. Delete the working branch + worktree (if any), sync
  the integration branch, archive the bolt's marker so subsequent runs do not
  resume it, and prompt the user to write a lore entry if the bolt produced
  architectural decisions worth preserving. Use after /divecode-merge.
triggers:
  - divecode cleanup
  - cleanup bolt
  - finish bolt
allowed-tools:
  - Bash
  - Read
  - Write
  - AskUserQuestion
---

# divecode-cleanup — terminal phase

You are running **divecode-cleanup**. The bolt is merged. Clean up local state and capture lore.

## Iron Laws

1. **Don't delete the worktree before merge is verified.** Re-check merge.md.
2. **Sync the integration branch** (`git pull --ff-only`) on the local clone so subsequent bolts start from latest.
3. **Always prompt for lore entry**, even briefly. Architectural learning is what makes the next bolt faster.
4. **Mark bolt status `merged`** in `bolt.yml` so `bolt-current` returns "no active bolt" for this project.

## Preamble

```bash
PROJ_DIR="${DIVECODE_PROJECT_DIR:-$PWD}"
DIVECODE_HOME="${DIVECODE_HOME:-$HOME/.divecode}"
[ -x "$DIVECODE_HOME/bin/divecode-bolt-current" ] || DIVECODE_HOME="$HOME/Trappist/divecode"

BOLT_INFO=$(bash "$DIVECODE_HOME/bin/divecode-bolt-current" --project "$PROJ_DIR" 2>&1)
BOLT_ID=$(printf '%s' "$BOLT_INFO" | grep -E '^bolt:' | head -1 | awk '{print $2}')
STATE_DIR="${DIVECODE_STATE_DIR:-$HOME/.divecode/state}"
BOLT_DIR="$STATE_DIR/bolts/$BOLT_ID"

[ -f "$PROJ_DIR/divecode/merge.md" ] || { echo "✗ no merge.md — bolt not merged?"; exit 1; }

echo "BOLT:     $BOLT_ID"
echo "BOLT_DIR: $BOLT_DIR"
```

## Workflow

### Step 1 — Worktree + branch cleanup
```bash
# If worktree was used (recorded in divecode/worktree.md)
WT=$(grep -E '^worktree_path:' "$PROJ_DIR/divecode/worktree.md" 2>/dev/null | awk '{print $2}')
BRANCH=$(grep -E '^branch:' "$PROJ_DIR/divecode/worktree.md" 2>/dev/null | awk '{print $2}')

if [ -n "$WT" ] && [ "$WT" != "no" ] && [ -d "$WT" ]; then
  git worktree remove "$WT"
  echo "removed worktree: $WT"
fi
# Branch deletion already happened via --delete-branch in merge; local cleanup:
git -C "$PROJ_DIR" branch -d "$BRANCH" 2>/dev/null || true
```

### Step 2 — Sync integration branch
```bash
TARGET=$(awk '/^pr:/{f=1;next} f && /^  target_branch:/{print $2; exit}' "$PROJ_DIR/.divecode/profile.yml" 2>/dev/null)
[ -z "$TARGET" ] && TARGET=main
git -C "$PROJ_DIR" checkout "$TARGET"
git -C "$PROJ_DIR" pull --ff-only
```

### Step 3 — Mark bolt merged
```bash
if [ -f "$BOLT_DIR/bolt.yml" ]; then
  sed -i.bak 's/^status: active/status: merged/' "$BOLT_DIR/bolt.yml" && rm "$BOLT_DIR/bolt.yml.bak"
  echo "marked bolt $BOLT_ID as merged"
fi
```

### Step 4 — Lore prompt
Use `AskUserQuestion`:

> "This bolt produced N architectural decisions (see design.md §6). Would you like to:"
> - **Auto-mirror to lore now** (uses §6 entries as-is) — recommended
> - Manually edit lore entries first
> - Skip lore for this bolt

If auto-mirror: write each Directive/Constraint/Rejected to `.divecode/lore/decisions/<bolt-id>-<name>.md` per the lore-entry template.

### Step 5 — Output cleanup.md
```
# cleanup.md
bolt:           <id>
worktree:       <removed | none>
branch:         <deleted>
integration:    <synced>
lore_entries:   <N>
status:         merged
```

## Done criteria
- Worktree removed (if applicable)
- Local branch deleted
- Integration branch synced
- Bolt status: merged
- Lore decision recorded (entries or "skipped")
