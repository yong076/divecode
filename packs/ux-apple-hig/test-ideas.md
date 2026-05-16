# test-ideas — ux-apple-hig

## Dynamic Type smoke test
For each screen, snapshot tests at `xxxLarge` and `accessibilityXXXLarge` content sizes. Visual diff against baseline. Fail if text clips, truncates, or overflows.

## Dark Mode snapshot per screen
Snapshot each screen in both Light and Dark. Eyeball or pixel-diff. Catches hardcoded colors.

## Safe area snapshot on every iPhone profile
Snapshot on iPhone SE (no notch), iPhone 15 (notch), iPhone 15 Pro (Dynamic Island). Assert all content visible.

## Touch target audit
Custom XCTest or accessibility audit: enumerate all `Button` / tappable elements. Assert hit area ≥ 44×44 points.

## VoiceOver label assertion
For every icon-only button, XCUITest asserts the accessibility label is non-empty and describes the action.

## Reduce Motion respected
Snapshot or behavioral test with Reduce Motion on: assert no spring/parallax animations fire; transitions cross-fade.

## Sheet vs nav decision recorded
For each modal/sheet/full-screen presentation, the design.md (or code comment) cites which HIG pattern applies. Code review enforces presence.

## Watch standalone smoke (if applicable)
Run Watch app with phone in airplane mode. Assert it shows useful state, not a "—" placeholder.
