---
name: divecode-prd
description: |
  PRD interrogation entry point — the product wedge of divecoding. Takes a
  rough PRD (path or pasted text), fires pattern-pack triggers, surfaces
  per-pack failure modes as a risk-map, and drives an interrogation loop
  that asks the 8-12 questions the PRD didn't answer. Produces design.md
  (Spec §2 populated from PRD), risk-map.md, and open-questions.md before
  any code is generated.

  Use when starting a new bolt with a written PRD. For cold-start (no PRD),
  fall through to /divecode-spec instead.
triggers:
  - divecode prd
  - dive prd
  - prd interrogation
  - interrogate this prd
  - check this prd
  - risk-map this prd
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - AskUserQuestion
---

# divecode-prd — PRD risk interrogation

You are running **divecode-prd**. The user has a rough PRD. The agent's job is **not to start building**. It is to:

1. Detect which domain patterns the PRD touches
2. Surface the failure modes those patterns are known to cause in production
3. Ask the 8-12 questions the PRD didn't answer
4. Hand back a risk-map + open-questions doc the user can refine before any code

This is divecoding's product wedge. Treat it that way.

## Iron Laws

1. **No code in this phase.** Not even pseudocode in the artifacts. If you find yourself writing implementation, stop — the loop isn't done.
2. **Every question has provenance.** Display `[pack-name]` prefix so the user knows why each question was asked.
3. **A question without an answer is a `TODO(decision-needed)` in design.md.** Never silently default.
4. **Triggers are deterministic** — the matcher's output is the source of truth. If a pack didn't fire, it didn't fire. Don't manually add packs you "think" apply.

## Preamble

```bash
PROJ_DIR="${DIVECODE_PROJECT_DIR:-$PWD}"
DIVECODE_HOME="${DIVECODE_HOME:-$HOME/.divecode}"
[ -x "$DIVECODE_HOME/bin/divecode-prd-triggers" ] || DIVECODE_HOME="$HOME/Trappist/divecode"
PACKS_DIR="$DIVECODE_HOME/packs"

mkdir -p "$PROJ_DIR/divecode"
DESIGN="$PROJ_DIR/divecode/design.md"
RISK_MAP="$PROJ_DIR/divecode/risk-map.md"
OPEN_QS="$PROJ_DIR/divecode/open-questions.md"

echo "DIVECODE_HOME: $DIVECODE_HOME"
echo "PACKS_DIR:     $PACKS_DIR  ($(ls "$PACKS_DIR" 2>/dev/null | wc -l | tr -d ' ') packs)"
```

## Workflow

### Step 1 — Locate or accept the PRD

If user invoked with a path: use it.
If user pasted PRD inline: write it to `divecode/prd-input.md` first.
If neither: ask the user to paste a PRD or specify a path. **Don't proceed without one** — that's what `/divecode-spec` is for.

### Step 2 — Fire triggers

```bash
bash "$DIVECODE_HOME/bin/divecode-prd-triggers" --prd <prd-path> --packs-dir "$PACKS_DIR"
```

Output: list of matched packs + which triggers fired.

### Step 3 — Sanity check with the user

> "From your PRD I detected: redis-cache, postgres-saas, admin-dashboard, vercel-serverless. Did I miss anything obvious? Did I match something irrelevant?"

Use `AskUserQuestion` if there's ambiguity. The user can manually add or remove packs at this point — that's recorded as a constraint in design.md §6.

### Step 4 — Render risk-map.md

For each matched pack, pull `failure-modes.md` via:
```bash
bash "$DIVECODE_HOME/bin/divecode-pack-read" --failures "$PACKS_DIR/<pack>"
```

Compose `risk-map.md`:
```markdown
# risk-map.md

## redis-cache (matched: redis, ttl, upstash)
<failure-modes content, abbreviated to titles + 1-line summary>

## postgres-saas (matched: postgres, neon)
...
```

Show the user the risk-map. Ask: "Does this match what you're worried about?" Adjust pack selection if not.

### Step 5 — Generate open-questions.md

For each matched pack, pull `questions.md`. Compose `open-questions.md` with provenance prefixes:
```markdown
# open-questions.md

## TTL & invalidation [redis-cache]
- What's the TTL? Why that number specifically?
- Which write paths invalidate this cache? List every one.
...

## Connection pool [postgres-saas]
- ...
```

Dedupe identical questions across packs (rare but happens for cross-cutting concerns like "rate limiting").

### Step 6 — Drive the interrogation

Walk through `open-questions.md` section by section. For each section:
- Quote the questions
- Use `AskUserQuestion` for ones with 2-4 distinct options
- Use free-form for genuinely open ones
- **Stop after each pack** — don't fire 12 questions in a row. Wait for batch answers.

After each pack's questions are answered, append decisions to `design.md` §6 Decision log AND to a "Decisions from PRD" section. Also mirror Constraints/Directives to `.divecode/lore/decisions/prd-<bolt>-<question-id>.md` (per v0.2 lore cascade).

### Step 7 — Populate design.md §2 from PRD

Use the PRD text + answered questions to fill design.md §2 Spec:
- Goal
- In-scope (from PRD)
- Out-of-scope (from PRD + new exclusions raised during interrogation)
- Acceptance criteria
- Observable behavior
- Dependencies
- Open risks (the questions still marked `TODO(decision-needed)`)

Leave §3 DDD, §4 Clean Arch, §5 SOLID, §7 UX for `/divecode-spec` and `/divecode-design` to fill in subsequent phases.

### Step 8 — Hand off

> "PRD interrogation complete. 3 artifacts in divecode/:
>   - design.md (§1 Interview + §2 Spec populated from PRD answers; §6 has N decisions recorded)
>   - risk-map.md (M packs, K failure modes flagged)
>   - open-questions.md (P questions, Q answered, R deferred as TODO)
>
> Next: review the artifacts. When ready, /divecode-spec to fill the remaining design.md sections, or /divecode-slice-plan if you want to jump straight to TDD-ready decomposition."

## Done criteria
- `design.md` exists with §1 + §2 + §6 populated
- `risk-map.md` exists with one section per matched pack
- `open-questions.md` exists with provenance-prefixed sections
- Every answered question is recorded in `design.md` §6
- Every deferred question is marked `TODO(decision-needed)` in design.md §2 Open risks
- User has acknowledged the artifacts before invoking next phase

## When to use

- **Use**: starting a new bolt with a written PRD, no matter how rough
- **Skip in favor of /divecode-spec**: cold start with only a vague idea ("I want to build an admin dashboard but haven't written it down")
- **Skip in favor of /divecode-audit**: project already in progress without a PRD
