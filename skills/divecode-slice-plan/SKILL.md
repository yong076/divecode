---
name: divecode-slice-plan
description: |
  Decompose design.md (or requirements.md + ARCHITECTURE.md for light) into TDD-ready
  slices. Each slice ≤ 50% of the agent's context window and produces a reviewable
  artifact. Profile-conditional fields: light requires goal + files + tests only;
  standard adds layer + aggregates + verification; strict additionally requires test
  case names drawn from acceptance criteria. Produces divecode/slice-plan.md.
  PAUSES at end for human review of design + slice-plan together. Use after
  /divecode-spec (or /divecode-arch for light) and before /divecode-worktree.
triggers:
  - divecode slice-plan
  - slice plan
  - decompose into slices
  - dive slice
allowed-tools:
  - Bash
  - Read
  - Write
  - AskUserQuestion
---

# divecode-slice-plan — TDD-ready decomposition

You are running **divecode-slice-plan**. The design is locked. Now decompose it into ordered, TDD-ready slices. Each slice is small enough that one human can review it in one sitting and one TDD red→green→refactor cycle fits in ~50% of an agent context window.

## Iron Laws

1. **Slice small.** If a slice's estimated diff is > 150 lines OR touches > 3 files OR mixes layers, split it.
2. **Order by dependency.** Foundation first. Data-layer first if usecases depend on it. Tests are first-class slices when test infra changes.
3. **Profile-conditional fields.** Don't ask `light` users about aggregates. Don't let `strict` skip test case names.
4. **Pause at end.** Chain pauses here per agent-flow `slice-plan.pause_after: true`. Do not auto-invoke worktree.

## Preamble

```bash
PROJ_DIR="${DIVECODE_PROJECT_DIR:-$PWD}"
DIVECODE_HOME="${DIVECODE_HOME:-$HOME/.divecode}"
[ -x "$DIVECODE_HOME/bin/divecode-detect" ] || DIVECODE_HOME="$HOME/Trappist/divecode"

PROFILE_FILE="$PROJ_DIR/.divecode/profile.yml"
PROFILE_KIND="light"
[ -f "$PROFILE_FILE" ] && PROFILE_KIND=$(grep -E '^kind:' "$PROFILE_FILE" | head -1 | awk '{print $2}')

TARGET="$PROJ_DIR/divecode/slice-plan.md"
if [ ! -f "$TARGET" ]; then
  cp "$DIVECODE_HOME/templates/slice-plan.md.template" "$TARGET" 2>/dev/null || \
    echo "# slice-plan.md" > "$TARGET"
fi

echo "PROFILE: $PROFILE_KIND"
echo "TARGET:  $TARGET"
echo "DESIGN:  $PROJ_DIR/divecode/design.md (standard+) or requirements.md+ARCH.md (light)"
```

## Workflow

### Step 1 — Read upstream artifacts
- standard+: `divecode/design.md` only
- light: `divecode/requirements.md` + `divecode/design/` + `divecode/ARCHITECTURE.md`

### Step 2 — Propose ordered slice list

Use `AskUserQuestion` only if the user wants to reorder. Otherwise present the proposed order and ask "OK?".

### Step 3 — Per slice, fill profile-conditional fields

**light fields (required)**:
- `goal` — one sentence
- `files expected to change`
- `test cases that will drive RED`

**standard fields (light + add)**:
- `layer scope` — domain / usecase / data / presentation (or combination)
- `aggregates touched`
- `verification command` — the exact bash to run after GREEN

**strict fields (standard + add)**:
- `test case names` MUST trace back to specific acceptance criteria IDs from design.md §2
- each slice has an explicit `Repository Pattern note` if it touches a data layer (per design.md §4 mandate)

### Step 4 — Size check

For each slice, estimate diff size. If > 150 lines, propose a split. Be explicit:

> "Slice 3 looks ~250 lines (covers both repo interface + impl + mapper). Suggest splitting into 3a (interface, ~50) / 3b (impl + DataSource composition, ~150) / 3c (mapper + tests, ~60). OK?"

### Step 5 — Pause marker

End the slice-plan.md with:

```
## Pause

⏸  **Chain pauses here.** Reviewer must read both `divecode/design.md` and `divecode/slice-plan.md` before invoking `divecode-worktree`.
```

Then **stop**. Do not invoke worktree. The next sub-skill is gated on human review.

## Done criteria

- All slices listed in dependency order
- All required fields filled per profile
- No slice exceeds estimated 150 lines (or has an explicit "intentionally larger because X" note)
- Pause marker present
- User has confirmed the order
