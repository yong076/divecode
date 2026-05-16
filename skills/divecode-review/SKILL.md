---
name: divecode-review
description: |
  Final review phase — spawn multi-reviewer in parallel: generalist + architecture-design
  specialist (mandatory) + any angles declared in profile.review_angles. Aggregate findings
  with severity (must-fix / should-fix / notes) and source angle. Cites paths as
  path/to/file:line. Use after /divecode-implement, before /divecode-fix-loop.
triggers:
  - divecode review
  - final review
  - review the bolt
  - pre-merge review
allowed-tools:
  - Bash
  - Read
  - Write
  - Agent
---

# divecode-review — multi-reviewer aggregation

You are running **divecode-review**. The implementation is done. Now spawn parallel reviewers and aggregate.

## Iron Laws

1. **Multiple eyes, parallel.** Never serial. Use the Agent tool to spawn at least 2 reviewers concurrently.
2. **Architecture-design specialist is MANDATORY** for every profile ≥ standard. Strict adds 2+ extra angles from `profile.review_angles`.
3. **Severity is opinionated.** Each finding gets `must-fix` / `should-fix` / `note`. No "FYI" without severity.
4. **Findings cite file:line.** Vague findings ("the auth code is messy") get rewritten or dropped.

## Preamble

```bash
PROJ_DIR="${DIVECODE_PROJECT_DIR:-$PWD}"
DIVECODE_HOME="${DIVECODE_HOME:-$HOME/.divecode}"
[ -x "$DIVECODE_HOME/bin/divecode-detect" ] || DIVECODE_HOME="$HOME/Trappist/divecode"

PROFILE_FILE="$PROJ_DIR/.divecode/profile.yml"
PROFILE_KIND="light"
[ -f "$PROFILE_FILE" ] && PROFILE_KIND=$(grep -E '^kind:' "$PROFILE_FILE" | head -1 | awk '{print $2}')

# Extra review angles (yaml list) — parse loosely
EXTRA_ANGLES=$(awk '/^review_angles:/{found=1;next} found && /^  - /{print $2} found && !/^  /{exit}' "$PROFILE_FILE" 2>/dev/null)

echo "PROFILE: $PROFILE_KIND"
echo "REVIEWERS to spawn:"
echo "  1. generalist"
if [ "$PROFILE_KIND" != "light" ]; then
  echo "  2. architecture-design (mandatory for standard+)"
fi
[ -n "$EXTRA_ANGLES" ] && echo "  3+. profile.review_angles: $EXTRA_ANGLES"
```

## Workflow

### Step 1 — Spawn reviewers in parallel

Use the Agent tool. **Send all reviewer Agent calls in a single message** so they run concurrently. Reviewer templates live at `$DIVECODE_HOME/templates/review/`:

- `generalist.md` (any profile)
- `architecture-design.md` (standard/strict mandatory — combines DDD + Clean Arch + SOLID lens)
- per-angle templates from `profile.review_angles` (e.g., `security.md`, `performance.md`, `dx.md`)

Each reviewer Agent receives:
- The bolt diff (`git diff <base>...HEAD`)
- The relevant artifact (design.md or req.md+ARCH.md)
- The reviewer template instructions

### Step 2 — Aggregate findings

Combine all reviewer outputs into `divecode/final-review.md` using this format:

```markdown
# final-review.md

## Summary
- must-fix: N
- should-fix: M
- notes: K

## Findings

### MF-1 [must-fix] [architecture-design] path/to/file.swift:42
<finding body>

### MF-2 [must-fix] [security] ...
```

Sort by severity (must-fix first), then by source angle.

### Step 3 — Deduplicate

If two reviewers raise the same finding, merge them and list both source angles. Don't show duplicates.

### Step 4 — Output decision

- Any `must-fix` → invoke `/divecode-fix-loop`
- Only `should-fix` / `notes` → ask user: "no must-fix. Proceed to /divecode-commit, or address should-fix first?"

## Done criteria

- All planned reviewers ran (didn't silently skip)
- `final-review.md` written and ordered
- Routing decision stated
