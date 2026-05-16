# UX / HIG / Accessibility checklist

Surface for every UI screen. Includes Apple HIG, Material, web a11y essentials.

## States (every screen — non-negotiable)
- [ ] **Ideal** — populated, happy path
- [ ] **Empty** — never been used, or filtered to nothing. Has CTA, not just "no data"
- [ ] **Loading** — skeleton (not spinner) for known structure; spinner only when structure unknown
- [ ] **Error** — what went wrong, what to try, who to contact. Not a stack trace
- [ ] **Edge** — very long content, very many items, very small viewport

## Interaction
- [ ] Primary action visually distinct (one per screen)
- [ ] Destructive actions — confirmation? Undo? (prefer undo over confirm)
- [ ] Long-press / right-click affordances?
- [ ] Drag-and-drop — keyboard alternative?

## Loading & feedback
- [ ] Anything > 100ms has loading indicator
- [ ] Anything > 1s has progress or skeleton
- [ ] Anything > 10s is moved to background with notification
- [ ] Optimistic UI for high-confidence operations?
- [ ] Error recovery — retry button (not just "try again later")

## Accessibility (web)
- [ ] Semantic HTML — `<button>` for buttons, `<a>` for navigation
- [ ] Keyboard navigation works for every interactive element
- [ ] Focus visible (do not remove `:focus-visible` outline)
- [ ] Tab order matches visual order
- [ ] ARIA labels for icon-only buttons
- [ ] Color contrast ≥ 4.5:1 for body, ≥ 3:1 for large text
- [ ] Color not the only signal (icon + color, not just color)
- [ ] `prefers-reduced-motion` honored
- [ ] `prefers-color-scheme` honored if relevant
- [ ] Screen reader tested (VoiceOver / NVDA)

## Apple HIG (iOS / macOS / iPadOS / watchOS / visionOS)
- [ ] Navigation pattern matches platform conventions
- [ ] Dynamic Type supported (no hard-coded font sizes)
- [ ] Dark Mode supported and tested
- [ ] Safe Areas respected (notch, home indicator)
- [ ] Touch targets ≥ 44pt
- [ ] Haptics — used purposefully, not gratuitously
- [ ] System gestures not blocked (swipe-back)
- [ ] Sheet vs full-screen vs popover — appropriate for context
- [ ] iOS: large title behavior, navigation bar style
- [ ] macOS: menu bar, window chrome, toolbar items
- [ ] Watch: complication, glance state, Digital Crown
- [ ] visionOS: ornaments, depth, attention regions

## Material Design (Android / web)
- [ ] Elevation matches semantic importance
- [ ] FAB — only one primary action per screen
- [ ] Snackbar for ephemeral feedback (not dialog)
- [ ] Bottom sheet vs modal vs dialog — context-appropriate
- [ ] Ripple feedback on touchables

## Forms
- [ ] Required vs optional visually distinguished
- [ ] Inline validation (real-time for format errors, on-blur for availability)
- [ ] Error messages near the field, not aggregated
- [ ] Field labels persistent (don't disappear when typing)
- [ ] Autocomplete attributes set (`autocomplete="email"`, etc.)
- [ ] Mobile: input type triggers correct keyboard (`type="email"`, `inputmode="numeric"`)
- [ ] Submit disabled vs error on submit — explicit choice
- [ ] Autosave or explicit save — explicit choice
- [ ] Unsaved changes warning on navigate-away

## Lists
- [ ] Sort default + sort options
- [ ] Filter UI placement
- [ ] Pagination model (cursor / infinite / numbered) **with reason**
- [ ] Selection model (none / single / multi) + bulk actions
- [ ] Item density configurable?
- [ ] Sticky headers / sticky filter bar?
- [ ] Pull-to-refresh (mobile)?

## Empty state copy
- [ ] Explains what this section is for
- [ ] Has a primary CTA (or explains why there isn't one)
- [ ] Tone matches product (encouraging, neutral, professional)

## Internationalization (if applicable)
- [ ] No concatenated strings ("You have {n} items")
- [ ] Plural rules (CLDR) used, not `n === 1 ? "" : "s"`
- [ ] RTL languages supported (mirrored layout)?
- [ ] Date / time / number formatting locale-aware
- [ ] Text expansion budget (German is ~30% longer than English)

## Performance perception
- [ ] First meaningful paint < 1s
- [ ] Optimistic UI for high-confidence operations
- [ ] Preload likely next interaction
- [ ] Animations respect frame budget (60/120fps)
