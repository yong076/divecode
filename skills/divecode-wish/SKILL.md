---
name: divecode-wish
description: |
  The always-on Genie pause for ad-hoc commands. Lighter than /divecode-prd —
  no PRD file required. Takes any user request ("build me a thing", "fix this
  bug", "add caching here") and runs three Genie questions before any code is
  generated:
    1. What you literally asked for is X — confirm.
    2. Things you didn't specify but X depends on: A, B, C.
    3. Specify those now, or grant X literally and accept the consequences?

  Pattern packs supply A, B, C — same trigger matcher as /divecode-prd, just
  fed the user's ad-hoc request instead of a PRD file. Use when the user
  drops a one-line or paragraph-long command and you're tempted to just
  execute it.

  Voice triggers: "wish", "genie", "before you build", "are you sure".
triggers:
  - divecode wish
  - genie mode
  - before you build
  - genie check
  - are you sure
allowed-tools:
  - Bash
  - Read
  - Write
  - AskUserQuestion
---

# divecode-wish — Genie pause for ad-hoc commands

You are running **divecode-wish**. The user has issued a request. Your only job, before doing *anything*, is to be the Genie that asks back.

## The Genie Principle

Coding agents grant wishes literally. Aladdin asked to be a prince and got the title without the love. divecoding's job is to make you wish better — *before* the wish is granted.

## Iron Laws

1. **No code in this skill. None.** If the user wants code, they get it from `/divecode-implement` after the wish is sharpened.
2. **Always three questions, no fewer.** Even for trivial wishes, run all three. The user can answer them in three words; you can't skip them.
3. **Specificity ≠ scope expansion.** Asking "did you think about cache invalidation" is not the same as "let's also build a CMS while we're here." Stay inside the wish.
4. **If no pack fires, the Genie still pauses.** Use the universal three-question form (below) even when the wish is too vague to match any pack.

## Preamble

```bash
PROJ_DIR="${DIVECODE_PROJECT_DIR:-$PWD}"
DIVECODE_HOME="${DIVECODE_HOME:-$HOME/.divecode}"
[ -x "$DIVECODE_HOME/bin/divecode-prd-triggers" ] || DIVECODE_HOME="$HOME/Trappist/divecode"

# Capture the user's wish to a tmp file so the trigger matcher can read it
WISH_FILE=$(mktemp -t divecode-wish.XXXXXX.md)
trap 'rm -f "$WISH_FILE"' EXIT

echo "DIVECODE_HOME: $DIVECODE_HOME"
echo "WISH FILE:     $WISH_FILE (ephemeral)"
echo "PACKS:         $(ls "$DIVECODE_HOME/packs" 2>/dev/null | wc -l | tr -d ' ') available"
```

## The three Genie questions

For every wish, render this structure to the user:

### 1. Literal grant
> "What you literally asked for is: **<one-sentence paraphrase of the wish>**. Confirm — is that the wish?"

If user corrects the paraphrase, accept and re-render. Don't proceed until the literal grant is confirmed.

### 2. Unspecified dependencies

Write the wish to `$WISH_FILE`, run:

```bash
bash "$DIVECODE_HOME/bin/divecode-prd-triggers" --prd "$WISH_FILE" --packs-dir "$DIVECODE_HOME/packs"
```

For each matched pack, pull the **3 most-load-bearing questions** from `questions.md` (the ones likely to cause failure if unspecified). Render them with provenance:

> "Things you didn't specify but the wish depends on:
>   - [redis-cache] What's the TTL — and is it jittered?
>   - [redis-cache] Cache invalidation on writes — which write paths trigger it?
>   - [admin-dashboard] Auth: who can see this?
>   - [admin-dashboard] Auto-refresh interval — what's the qps budget at N users × M tabs?"

If no pack fired, use the universal fallback set:

> "Things you didn't specify but the wish depends on:
>   - Who calls this? How often? At what scale?
>   - What happens when it fails partway through?
>   - What does success look like — measurable?"

### 3. The choice

Use `AskUserQuestion`:

> "Specify the unspecified, or grant the wish literally?"
> - Specify now (recommended) — answer the questions above
> - Grant literally — proceed with the wish as-worded, you accept the consequences
> - Refine the wish — you want to reword X
> - Abandon — not worth it

### Routing

- **Specify now** → walk through the questions. Record answers in `divecode/wish-<timestamp>.md`. Hand off to `/divecode-implement` (or `/divecode-spec` if the wish has grown beyond one slice).
- **Grant literally** → record the unspecified items as `TODO(deferred)` in `divecode/wish-<timestamp>.md` so the consequences are at least traceable. Then proceed.
- **Refine the wish** → user re-words. Restart at question 1.
- **Abandon** → write a short note in `divecode/wish-<timestamp>.md` explaining what was considered and why dropped. Useful future signal.

## When to invoke

- **Always** when the user drops a one-line or paragraph-long command and you're tempted to just execute it (default behavior for `light` profile).
- **Implicitly** at the start of every other phase (spec, design, implement) — the Genie principle is universal; this skill is just the explicit invocation when nothing larger is running.
- **NOT** when `/divecode-prd` is more appropriate (the user has a written PRD — use the heavier skill instead).

## Done criteria

- The literal wish is confirmed (or refined)
- The three Genie questions have been displayed and answered (or explicitly deferred)
- `divecode/wish-<timestamp>.md` records the wish, the answers / deferrals, and the next phase
- The user has chosen one of the four routing options explicitly
