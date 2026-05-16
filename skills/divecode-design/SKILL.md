---
name: divecode-design
description: |
  UI/UX design phase of divecode. Generates lightweight HTML mockups for each
  major screen/state, then runs a question loop ("did you think about empty state?
  loading? error? offline? 10,000 items? accessibility?"). Surfaces UX niche knowledge
  from checklists/ux-hig.md (Apple HIG, Material, a11y). If open-design is installed,
  delegates the design-system work to it. Produces divecode/design/*.html and updates
  requirements.md with UX decisions. Use after /divecode-spec, before /divecode-arch.
triggers:
  - divecode design
  - dive design
  - mockup the screens
  - design the UI properly
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - AskUserQuestion
---

# divecode-design — UX mockup interrogation

You are the **design interrogator**. You generate quick HTML wireframes for each screen, then use them as forcing functions to ask the user about cases they didn't think about (empty, loading, error, edge dimensions, accessibility, motion).

**The HTML mockup is not the deliverable. The conversation it enables is.**

## Iron Laws

1. **Mockup first, then interrogate.** Show, then ask "did you think about this?"
2. **Every screen has 5 states**: ideal, empty, loading, error, edge (very-long content, very-many items, very-small viewport).
3. **HIG / Material / a11y is mandatory reading.** Pull from `checklists/ux-hig.md`.
4. **Mobile + desktop + (if Apple platform) Watch / Vision** — explicitly consider each.

## Preamble

```bash
PROJ_DIR="${DIVECODE_PROJECT_DIR:-$(pwd)}"
DIVECODE_HOME="${DIVECODE_HOME:-$HOME/.divecode}"
DESIGN_DIR="$PROJ_DIR/divecode/design"
mkdir -p "$DESIGN_DIR"

# Check if open-design is installed locally — if so, prefer delegating
if [ -d "$HOME/Trappist/open-design" ] || command -v open-design >/dev/null 2>&1; then
  echo "OPEN_DESIGN: available — consider delegating brand/design-system work"
else
  echo "OPEN_DESIGN: not found — using inline HTML mockups"
fi

echo "REQS: $PROJ_DIR/divecode/requirements.md"
echo "DESIGN_DIR: $DESIGN_DIR"
```

## Workflow

### Step 1 — Enumerate screens

Read `divecode/requirements.md`. From the user-facing scope, list every screen / view / panel. Confirm the list with the user before proceeding.

For each screen, identify:
- Primary platform (mobile / desktop / both)
- Entry point (how user gets here)
- Primary action (what they came to do)

### Step 2 — For each screen, generate 5-state HTML mockup

Create `divecode/design/<screen-slug>.html`. Single self-contained HTML file with all 5 states stacked vertically, each clearly labeled:

```html
<!DOCTYPE html>
<html><head>
<meta charset="utf-8">
<title>Mockup: <screen-name></title>
<style>
  body { font: 14px system-ui; max-width: 1200px; margin: 2rem auto; padding: 0 1rem; }
  .state { border: 1px solid #ddd; border-radius: 8px; margin-bottom: 2rem; }
  .state-label { background: #f5f5f5; padding: .5rem 1rem; font-weight: 600; }
  .state-body { padding: 1rem; min-height: 200px; }
  /* + screen-specific styles */
</style>
</head><body>
<h1>Mockup: <screen-name></h1>
<section class="state"><div class="state-label">1. Ideal state</div><div class="state-body">...</div></section>
<section class="state"><div class="state-label">2. Empty state</div><div class="state-body">...</div></section>
<section class="state"><div class="state-label">3. Loading state</div><div class="state-body">...</div></section>
<section class="state"><div class="state-label">4. Error state</div><div class="state-body">...</div></section>
<section class="state"><div class="state-label">5. Edge state (overflow / extreme)</div><div class="state-body">...</div></section>
</body></html>
```

Keep it dependency-free. Inline CSS. No external fonts. The user should be able to `open divecode/design/<file>.html` and see it instantly.

### Step 3 — The interrogation loop (per screen)

After generating each mockup, **ask the user to open it**, then ask the questions below. Use `AskUserQuestion` for discrete choices.

Universal questions (every screen):
- "Empty state copy — encouraging or just informative?"
- "Loading state — skeleton, spinner, or progress %?"
- "Error state — retry button, contact support link, both?"
- "What's the keyboard navigation order? (tab order)"
- "Screen reader label for the primary action?"
- "What happens on slow network (1s+ load)?"
- "What happens offline?"

Surface from `checklists/ux-hig.md` based on platform:
- iOS: navigation bar style, large title, swipe-back, dynamic type
- macOS: window chrome, menu bar items, keyboard shortcuts
- Web: focus rings, ARIA roles, color contrast, prefers-reduced-motion
- Watch: complication, glance state, Digital Crown affordance

For lists specifically:
- "Sort default? Sort options exposed?"
- "Filter UI — sidebar, top bar, or modal?"
- "Pagination — infinite scroll, load more, or numbered pages? **Why that choice?**"
- "Selection — single, multi, or none? Bulk actions?"
- "What does it look like with 0 / 1 / 10 / 1,000 / 100,000 items?"

For forms specifically:
- "Validation — inline, on submit, or both?"
- "Required vs optional — visually distinguished how?"
- "Autosave or explicit save?"
- "What happens if user navigates away with unsaved changes?"

### Step 4 — Update requirements.md

For each screen-level decision made, append to `divecode/requirements.md` under a new "UX decisions" section. Show the diff.

### Step 5 — Delegation to open-design (optional)

If the user wants real brand work (typography system, color tokens, component library), suggest:

> "본격 design system은 open-design에 위임하는 게 좋을 것 같아요. 거기서 typography/color/components 잡고 오면, divecode는 그걸 받아서 screen-state mockup만 다시 생성할게요."

## Done criteria

`divecode/design/` is "done" when:
- Every screen from requirements has a mockup file
- All 5 states are rendered for each
- The interrogation loop has been completed for each
- `requirements.md` has a "UX decisions" section reflecting the answers

Then suggest `/divecode-arch`.
