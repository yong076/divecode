# failure-modes — ux-apple-hig

## Hard-coded font sizes break Dynamic Type
App ships with `Text("Hello").font(.system(size: 14))`. Users with Dynamic Type set large see the same 14pt. Accessibility audit flags it; App Review may reject.

**Detection signal**: enable Dynamic Type at the largest setting in the simulator — does any text stay the same size?

## Dark Mode broken because colors are hardcoded
`Color.white` on a card. Looks fine in Light Mode. In Dark Mode it's a glaring white card on dark chrome.

**Detection signal**: toggle the appearance picker; scan every screen.

## Safe areas ignored — content under notch / home indicator
Custom layout uses GeometryReader or absolute positioning. Looks fine in old iPhone simulator. Real iPhone 15 Pro: notch eats the title; home indicator overlaps the CTA.

**Detection signal**: TestFlight reports from users with newer devices; manual test on real device.

## 44pt touch target violation
Tappable icon is 24pt. Adjacent icons crowd it. Users miss-tap. Accessibility audit fails.

**Detection signal**: HIG-compliance check; iOS Accessibility Inspector flags it.

## Modal sheet that should have been navigation
Used `.sheet()` for a screen that conceptually drills into detail. User swipes down expecting "go back," loses their work because that's "cancel" in sheet semantics.

**Detection signal**: support tickets about "I lost my form when I swiped"; modal vs nav misalignment with information architecture.

## VoiceOver labels missing on icon-only buttons
`Button { Image(systemName: "trash") }` reads as "Image" in VoiceOver. Blind users have no idea what the button does.

**Detection signal**: enable VoiceOver in simulator and tab through every screen.

## Watch app assumes phone connectivity
Complications and glance show "—" when phone isn't reachable. Watch user has a useless screen for the 15% of the day their phone is in another room.

**Detection signal**: turn off phone Bluetooth; check Watch experience.

## Keyboard covers the field being edited
Form scrolls but the active text field disappears under the keyboard because no `ScrollViewReader.scrollTo` on focus.

**Detection signal**: tap a field near the bottom of a form on a real device; can you see what you're typing?

## Animations that don't respect Reduce Motion
Heavy parallax / spring animations everywhere. Users with `Reduce Motion` enabled feel ill or can't use the app.

**Detection signal**: enable Reduce Motion in Settings; check every animation respects it.
