# example-patterns — ux-apple-hig

## Dynamic Type-aware text

```swift
// Bad: locks size, breaks Dynamic Type
Text("Hello").font(.system(size: 14))

// Good: scales with user preference
Text("Hello").font(.body)
// Or for custom sizing that still respects Dynamic Type:
Text("Hello").font(.system(.body, design: .rounded))
```

## Dark Mode-aware colors via asset catalog

```swift
// Define in Assets.xcassets with Light + Dark appearance variants
Text("Hello")
    .foregroundStyle(Color("PrimaryText"))   // adapts automatically
    .background(Color("CardBackground"))
```

Avoid `Color.white`, `Color.black`, `Color(red:green:blue:)` in views — use semantic asset colors.

## Safe area + keyboard avoidance

```swift
ScrollView {
    VStack(spacing: 16) {
        ForEach(fields) { field in
            TextField(field.placeholder, text: $field.value)
                .id(field.id)
        }
    }
    .padding()
}
.scrollDismissesKeyboard(.interactively)
.safeAreaInset(edge: .bottom) {
    SubmitButton()
}
```

## VoiceOver labels on icon buttons

```swift
Button {
    delete(item)
} label: {
    Image(systemName: "trash")
}
.accessibilityLabel("Delete \(item.name)")
.accessibilityHint("Removes this item permanently")
```

## Reduce Motion respect

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

var body: some View {
    HStack { ... }
        .animation(reduceMotion ? nil : .spring(), value: state)
}
```

## Sheet vs full-screen vs popover (HIG)

```swift
// Sheet — modal task user can complete or dismiss
.sheet(isPresented: $showingEdit) { EditView() }

// Full-screen — focused immersive flow (onboarding, video player)
.fullScreenCover(isPresented: $onboarding) { OnboardingView() }

// Popover — contextual menu/info near the tap source (iPad/macOS)
.popover(isPresented: $showingInfo) { InfoView() }
```

Pick by user intent, not visual preference.
