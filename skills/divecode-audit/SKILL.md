---
name: divecode-audit
description: |
  Inception sub-phase for in-progress projects. Reads existing source + .md docs +
  sibling repos + relevant OSS ecosystem to surface SILENT DECISIONS (those made
  by action or omission without recorded rationale). Produces divecode/audit-<feature>.md.
  Auto-invoked from /divecode entry when in-progress detected (feature/* branch or
  existing source on main). Use when starting divecode on an existing project, or
  asked to "audit this feature", "what decisions are silent", "review the in-flight work".
triggers:
  - divecode audit
  - audit this feature
  - audit insights
  - what silent decisions
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - AskUserQuestion
---

# divecode-audit — retroactive interrogation

You are running **divecode-audit**. The project is already in progress. The point is NOT to reverse-engineer a spec — it's to surface **decisions that were made silently (by action or omission)** and force a deliberate yes/no on each, then compare against the wider OSS ecosystem.

## Iron Laws (specialized for audit)

1. **Distinguish recorded vs silent decisions.** If `docs/*-status.md` or `docs/*-plan.md` already explain a choice with rationale, it's recorded — don't relitigate. Surface only the gaps.
2. **Compare with the ecosystem.** For each silent decision, find 1-3 similar OSS projects, see how they decided, name them, and ask "why is yours different?"
3. **One audit doc per feature, not per project.** Scope to the in-flight feature (branch name or user-specified). Whole-project audits are too broad to be actionable.
4. **Hand the doc back to the user as input to spec**, not as a finished artifact.

## Preamble

```bash
PROJ_DIR="${DIVECODE_PROJECT_DIR:-$PWD}"
DIVECODE_HOME="${DIVECODE_HOME:-$HOME/.divecode}"
[ -x "$DIVECODE_HOME/bin/divecode-sibling-repos" ] || DIVECODE_HOME="$HOME/Trappist/divecode"

echo "PROJECT:  $PROJ_DIR"
echo "BRANCH:   $(git -C "$PROJ_DIR" branch --show-current 2>/dev/null || echo 'not a git repo')"
echo "FEATURE:  ${DIVECODE_FEATURE:-(derive from branch)}"
echo ""
echo "=== Sibling repos ==="
bash "$DIVECODE_HOME/bin/divecode-sibling-repos" "$PROJ_DIR" || true
echo ""
echo "=== Existing planning docs ==="
find "$PROJ_DIR/docs" -maxdepth 2 -iname '*plan*.md' -o -iname '*status*.md' -o -iname '*spec*.md' 2>/dev/null | head -10
```

## Workflow

### Phase 1 — Scope

1. Derive the feature being audited (from branch name `feature/<X>` or from explicit user input).
2. Confirm with the user before scoping wider than the feature.

### Phase 2 — Read

In order:
1. Project `README.md`, `CHANGELOG.md`
2. Any `docs/<feature>*.md` (these often contain 50-80% of the rationale)
3. Source files touched by `git diff main...HEAD`
4. The sibling repos enumerated by `divecode-sibling-repos` — at minimum their `README.md` and any `*insights*.md` / `*<feature>*.md`

Goal: build a mental model of what's in flight and what neighboring repos do with the same data.

### Phase 3 — Surface silent decisions (the value-add)

For each non-trivial choice detected in the diff, classify:
- **Recorded** — found in a planning/status doc with rationale → skip
- **Silent** — made by action or omission, no rationale recorded → include in audit doc

For silent decisions, build a table:

| # | Decision | Where (file:line or doc anchor) | Rationale recorded? | Status |
|---|---|---|---|---|

Status values: `accepted-bug`, `drift`, `will-block-X`, `inconsistent`, `accepted`, `manual-maintenance debt`, `perf risk`, etc. — be specific.

### Phase 4 — Ecosystem comparison

For each silent decision (and a few key recorded ones), find 2-3 similar OSS projects via:
- `WebSearch` for the category + key concern
- Inspection of sibling repos
- Known-tools list (see `$DIVECODE_HOME/checklists/`)

Table format:

| Concern | this project | OSS X | OSS Y | OSS Z | What it suggests |
|---|---|---|---|---|---|

### Phase 5 — Sharpest interrogation questions

Pick 3-5 questions (use `AskUserQuestion`, ≤4 options each). Each question must:
- Cite **evidence** (file:line, doc anchor, or OSS comparison row)
- Offer 2-3 concrete decisions, not just "what do you think"
- Mark the recommendation explicitly

### Phase 6 — Record decisions back into the audit doc

For each answered question, append:

```
### Q<N> → <chosen option>
**Action**: <concrete next step>
**Why**: <reason, citing evidence from Phase 4>
```

Also auto-write each decision as a `Constraint` / `Rejected` / `Directive` lore entry under `.divecode/lore/decisions/audit-<feature>-q<n>.md` (via `bin/divecode-lore-cite` schema).

## Output

`<project>/divecode/audit-<feature>.md` following the template at `$DIVECODE_HOME/templates/audit.md.template`.

## Done criteria

The audit is "done" when:
- Every silent decision in the table has a status
- 3-5 sharpest questions have been interrogated and answered
- Lore entries mirrored to `.divecode/lore/decisions/`
- The doc ends with a "Decisions made (<date>)" section feeding back into `/divecode-spec`

## When to invoke

- Auto: from `/divecode` entry when project is in-progress
- Manual: when user says "audit this feature", "what decisions are silent", or after an unfamiliar branch hand-off
- Re-run: after a major refactor — it's healthy to re-audit periodically
