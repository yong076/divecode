---
name: divecode-fix-loop
description: |
  Address review findings from final-review.md. Max 3 rounds; escalates to user if
  must-fix items remain after round 3. Tests stay green after each round. Use after
  /divecode-review when must-fix findings exist; before /divecode-commit.
triggers:
  - divecode fix-loop
  - fix review findings
  - address must-fix
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - AskUserQuestion
---

# divecode-fix-loop — bounded fix iteration

You are running **divecode-fix-loop**. Address must-fix findings, re-verify, repeat up to 3 rounds.

## Iron Laws

1. **Tests stay green after every round.** If a fix breaks tests, that's a regression — fix the fix.
2. **Max 3 rounds.** Hitting 3 with remaining must-fix means escalate to user, do not silently grind further.
3. **Each round produces a delta to `fix-loop.md`.** Audit trail matters.
4. **Don't address should-fix in this loop.** Stay focused.

## Preamble

```bash
PROJ_DIR="${DIVECODE_PROJECT_DIR:-$PWD}"
REVIEW="$PROJ_DIR/divecode/final-review.md"
LOG="$PROJ_DIR/divecode/fix-loop.md"

[ -f "$REVIEW" ] || { echo "no final-review.md found"; exit 1; }
MUST_FIX_COUNT=$(grep -c '^### .*\[must-fix\]' "$REVIEW" 2>/dev/null || echo 0)
echo "must-fix items: $MUST_FIX_COUNT"
```

## Workflow

### Per round
1. For each `must-fix` finding, apply the change.
2. Re-run profile gates (`bash $DIVECODE_HOME/bin/divecode-tdd-gate ...` per affected slice + `divecode-repo-pattern-check`).
3. Append a delta entry to `fix-loop.md`:
   ```
   ## Round <N> — <date>
   ### Fixed
   - MF-1: <one-line summary>
   ### Remaining must-fix
   - MF-3: <if not yet addressed>
   ### Gate results
   - tests: PASS|FAIL
   - repo-pattern: OK|<issues>
   ```
4. If `must-fix` count is 0, exit loop with "all must-fix resolved".
5. Else if round < 3, loop.
6. Else (round == 3 with remaining): **escalate** — use `AskUserQuestion` to ask the user:
   > "3 rounds elapsed, must-fix remain (list). Options: (a) accept and merge with known issues recorded in lore, (b) extend to 1 more round, (c) abandon this bolt."

## Done criteria

- All must-fix addressed OR explicit user decision recorded in fix-loop.md
- Tests + gates green
- `fix-loop.md` has per-round entries
