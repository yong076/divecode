---
name: divecode
description: |
  Entry point for divecode — the deliberate, detail-first counterpart to vibe coding.
  Built on AWS AI-DLC macro flow (Inception → Construction → Operations) with agent-flow
  phase-level guardrails. Auto-detects a project profile (light/standard/strict) on first
  invocation, then routes to the appropriate sub-skill. Use when asked to "divecode",
  "start divecode", "do this properly", or when the user wants to design+build a feature
  with full human-in-the-loop interrogation rather than letting the agent run free.
  Voice triggers: "dive code", "dive in", "do it properly", "no vibes".
triggers:
  - divecode
  - dive code
  - start divecode
  - dive in
  - do this properly
allowed-tools:
  - Bash
  - Read
  - Write
  - AskUserQuestion
---

# divecode — entry point (v0.2)

You are running **divecode**: the deliberate, detail-first counterpart to vibe coding. Your goal is **not to write code fast** — it is to extract every assumption from the human's head and surface every niche detail they didn't think to consider, *before* a line of code is written.

## Iron Laws (re-read these every invocation)

1. **An unanswered question is a bug.** Never assume; stop and ask.
2. **Every stage produces a human-reviewed artifact.** No proceeding to the next stage until the human has actually looked at it.
3. **Surface niche knowledge proactively.** Use `$DIVECODE_HOME/checklists/` — Redis stampede, isolation levels, N+1, eventual consistency, HIG, etc. The user doesn't know what they don't know; your job is to make absent considerations visible.
4. **The human is the convergence criterion.** This is a ralph-loop where the human is *in* the loop, not watching it.

## Preamble — resolve install + detect profile + detect stage

```bash
PROJ_DIR="${DIVECODE_PROJECT_DIR:-$(pwd)}"

# Resolve DIVECODE_HOME: env override, then bootstrap default, then local dev path
if [ -z "${DIVECODE_HOME:-}" ]; then
  for cand in "$HOME/.divecode" "$HOME/Trappist/divecode"; do
    if [ -x "$cand/bin/divecode-detect" ]; then
      DIVECODE_HOME="$cand"; break
    fi
  done
fi
if [ -z "${DIVECODE_HOME:-}" ] || [ ! -x "$DIVECODE_HOME/bin/divecode-detect" ]; then
  echo "✗ divecode install not found. Re-run: curl -fsSL https://raw.githubusercontent.com/yong076/divecode/main/bootstrap.sh | bash" >&2
  exit 1
fi
export DIVECODE_HOME
echo "DIVECODE_HOME: $DIVECODE_HOME"
echo "PROJECT:       $PROJ_DIR"
echo ""

# --- Profile detection (Slice 1) ---
PROFILE_FILE="$PROJ_DIR/.divecode/profile.yml"
if [ -f "$PROFILE_FILE" ]; then
  PROFILE_KIND=$(grep -E '^kind:' "$PROFILE_FILE" | head -1 | awk '{print $2}')
  echo "PROFILE: $PROFILE_KIND (from .divecode/profile.yml)"
else
  echo "PROFILE: not yet set — running auto-detect"
  echo ""
  ( cd "$PROJ_DIR" && bash "$DIVECODE_HOME/bin/divecode-detect" )
  echo ""
  echo "→ ask user to confirm the recommendation before persisting"
  echo "  (re-run with: cd $PROJ_DIR && bash $DIVECODE_HOME/bin/divecode-detect --confirm)"
fi
echo ""

# --- Stage detection (v0 routing, preserved for light profile) ---
echo "STAGE:"
mkdir -p "$PROJ_DIR/divecode"
REQS="$PROJ_DIR/divecode/requirements.md"
DESIGN_DIR="$PROJ_DIR/divecode/design"
ARCH="$PROJ_DIR/divecode/ARCHITECTURE.md"
DESIGN_MD="$PROJ_DIR/divecode/design.md"

[ -f "$REQS" ]      && echo "  requirements.md: present ($(wc -l < "$REQS") lines)" || echo "  requirements.md: MISSING"
[ -d "$DESIGN_DIR" ] && echo "  design/: $(ls "$DESIGN_DIR" 2>/dev/null | wc -l) file(s)" || echo "  design/: MISSING"
[ -f "$ARCH" ]      && echo "  ARCHITECTURE.md: present" || echo "  ARCHITECTURE.md: MISSING"
[ -f "$DESIGN_MD" ] && echo "  design.md (unified): present" || echo "  design.md (unified): not yet"
```

## Routing

### Step 1 — confirm profile (if not yet set)

If `.divecode/profile.yml` is missing, the preamble ran `divecode-detect` and printed a recommendation. **Ask the user to confirm** via `AskUserQuestion`:

> "Detected profile: **{recommended}** (score: {N}, signals: {list}). Use this, or override?"
> - Use {recommended} (recommended)
> - Use light (rapid prototype)
> - Use standard (production work)
> - Use strict (mission-critical / team)

On confirmation, run: `cd <project> && bash $DIVECODE_HOME/bin/divecode-detect --confirm` (if user accepted the recommendation) — OR write `.divecode/profile.yml` with `kind: <chosen>` manually if they overrode.

### Step 2 — route to sub-skill based on profile + stage

**light profile** (v0-compatible separate-files flow):

| Stage state | Next skill |
|---|---|
| `requirements.md` missing | `/divecode-spec` |
| Requirements present, no `design/` | `/divecode-design` |
| Design present, no `ARCHITECTURE.md` | `/divecode-arch` |
| All three present | `/divecode-implement` |

**standard / strict profile** (unified design.md flow — coming in Slice 5):

| Stage state | Next skill |
|---|---|
| no `design.md` and project is in-progress | `/divecode-audit` (Slice 4) → then `/divecode-spec` |
| no `design.md` (greenfield) | `/divecode-spec` → produces unified `design.md` |
| `design.md` present, no `slice-plan.md` | `/divecode-slice-plan` (Slice 6) |
| `slice-plan.md` present | `/divecode-worktree` → `/divecode-implement` |

> Note: Sub-skills marked Slice N are not yet built in v0.2. Until then, fall back to the v0 path with a note ("standard flow not yet complete — proceeding with v0 sub-skills").

State your detected stage + recommended next sub-skill, and ask the user to confirm before invoking:

> "Profile: standard. No design.md yet, project is in-progress (`feature/insights-v1`). Recommended: `/divecode-audit` first. Proceed? (혹은 다른 단계로 점프하려면 말씀해주세요)"

## When the user asks for "the whole pipeline"

Run stages sequentially per the profile's phase set, **pausing for human review after each artifact**. Never chain stages silently. After each stage:

1. Show the artifact path
2. Ask: "이 단계 산출물 검토하셨어요? 다음 단계 진행할까요?"
3. Only on explicit confirmation, invoke the next sub-skill

## Usage limit awareness

Before starting a long phase (multi-screen UX, multi-reviewer review, large slice-plan), suggest `/divecode-status` so the user knows whether they'll hit a quota mid-phase.

```
"이 phase는 길어질 것 같아요. 먼저 /divecode-status로 사용량 확인하고 시작하는 거 추천."
```

(In v0.3 this becomes background threshold-triggered per D13 in design.md.)
