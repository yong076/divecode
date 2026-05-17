---
name: divecode-humanize
description: |
  Strip AI tells from a markdown file (Korean or English) while preserving
  meaning. Single-pass workflow: scan with bin/divecode-humanize-scan,
  apply targeted rewrites per checklists/humanize-{ko,en}.md taxonomy,
  re-scan to verify, output a before/after report. Hard guard: change rate
  > 30% warns, > 50% halts. Use when asked to "humanize this", "AI 티
  없애줘", "drop the AI tone", "윤문해줘", or to post-process drafted text
  before publishing.

  Korean taxonomy is a focused subset of im-not-ai
  (https://github.com/epoko77-ai/im-not-ai). English taxonomy is divecode's
  own collection. Use im-not-ai directly for deeper Korean analysis with
  academic-cited patterns.
triggers:
  - divecode humanize
  - humanize this
  - ai 티 없애
  - strip ai tone
  - 윤문해줘
  - drop ai tells
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - AskUserQuestion
---

# divecode-humanize — strip AI tells from text

You are running **divecode-humanize**. Take a markdown file, detect AI-tell
patterns, rewrite the offending spans, re-verify, hand back a clean file
plus a report. Korean and English supported in one pass.

## Iron Laws

1. **Meaning preserved to the letter.** Proper nouns, numbers, dates, direct
   quotes, code, file paths, technical identifiers are touched **zero** times.
2. **Targeted rewrites only.** Detected spans get edited; untouched lines stay
   untouched. Do not rewrite the whole file.
3. **30 % change rate is a warning. 50 % is a halt.** Past 50 %, roll back and
   report. The user can re-invoke with explicit override.
4. **Genre and register preserved.** A technical README stays a technical
   README. A formal article stays formal. No reframing into a different voice.

## Preamble

```bash
PROJ_DIR="${DIVECODE_PROJECT_DIR:-$PWD}"
DIVECODE_HOME="${DIVECODE_HOME:-$HOME/.divecode}"
[ -x "$DIVECODE_HOME/bin/divecode-humanize-scan" ] || DIVECODE_HOME="$HOME/Trappist/divecode"
SCAN="$DIVECODE_HOME/bin/divecode-humanize-scan"
TAXONOMY_KO="$DIVECODE_HOME/checklists/humanize-ko.md"
TAXONOMY_EN="$DIVECODE_HOME/checklists/humanize-en.md"

echo "SCAN:        $SCAN"
echo "TAXONOMY_KO: $TAXONOMY_KO"
echo "TAXONOMY_EN: $TAXONOMY_EN"
```

## Workflow

### Step 1 — locate input

User passes a file path. If they pasted text, write to a tmp file first.
Confirm the file exists and is markdown.

### Step 2 — initial scan

```bash
bash "$SCAN" "<file>" > /tmp/divecode-humanize-before.txt
cat /tmp/divecode-humanize-before.txt
```

Output has locale, word count, and one section per fired pattern (with ID,
severity, count, threshold). If `s1_hits=0` and the user did not force
re-run, say "clean — nothing to rewrite" and exit.

### Step 3 — read the taxonomy

```bash
# Auto-pick based on the scan's detected locale
if grep -q '^locale: ko' /tmp/divecode-humanize-before.txt; then
  cat "$TAXONOMY_KO"
else
  cat "$TAXONOMY_EN"
fi
```

Internalize the rewrite columns. Each fired pattern has a recipe.

### Step 4 — read the input file and plan targeted edits

Read the file fully. For each fired pattern, find the exact spans that
matched. For each span, decide the rewrite per the taxonomy's "Rewrite"
column. Keep notes — you will need them for the report.

**Anti-patterns to refuse to apply:**
- Wholesale rewriting of paragraphs that had no hit.
- Adding metaphors, similes, or rhetorical flourishes the original did not
  have. (Adding voice = adding fabrication, not humanizing.)
- Touching anything inside fenced code blocks, inline code (`...`), tables,
  YAML frontmatter, URLs, or HTML.
- Translating between English and Korean. Match the locale of the source.

### Step 5 — apply edits

Use the Edit tool for each span. Show the diff to the user mid-flow if there
are more than 8 edits.

### Step 6 — re-scan and verify

```bash
bash "$SCAN" "<file>" > /tmp/divecode-humanize-after.txt
diff /tmp/divecode-humanize-before.txt /tmp/divecode-humanize-after.txt | head -40
```

Check change rate via `git diff --stat` or `diff -u | grep -c '^[+-]'`. If
change rate > 50 %, **roll back the edits** and tell the user: "change rate
exceeded 50 %, rolled back. Re-invoke with `--allow-large-rewrite` if you
really want this."

### Step 7 — write the report

Use `templates/humanize-report.md.template` (or compose inline). Sections:

1. **Summary** — locale, before s1_hits vs after, change rate, grade (A/B/C/D
   per the taxonomy's grade rules).
2. **Per-pattern before / after** — table of (ID, before count, after count,
   notes).
3. **Examples** — 3 representative before / after pairs.
4. **Residual issues** — anything still over threshold, with reason ("kept
   because removing would change meaning" / "user override accepted").

Save the report alongside the file: `<file>.humanize-report.md`.

## When to invoke

- `divecode humanize <file>` — explicit run
- After drafting a README, blog post, or design doc with AI assistance
- Before publishing anything customer-facing
- Skip for: code comments inside source files (different register), commit
  messages (already short), changelogs (already terse)

## Done criteria

- `s1_hits` decreased; ideally to 0
- Change rate ≤ 30 % (or explicit user override recorded)
- Report file written
- User has acknowledged the diff before the file is considered final
- Grade is A or B; C/D triggers a "re-run?" prompt
