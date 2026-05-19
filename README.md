# PinEntryKit

A polished SwiftUI PIN entry view with a fully custom numeric keypad — no system keyboard involved. Drop it in via Swift Package Manager and get animated dot indicators, async validation, biometric support, haptic feedback, and error shake out of the box.

---

## Preview

<img width="2599" height="1548" alt="Frame 3" src="https://github.com/user-attachments/assets/32f5f451-f261-49cf-b7e6-1b225529191c" />

---

## Features

- **Custom keypad** — fully hand-built numeric pad; the system keyboard never appears
- **Animated dot indicators** — spring-bounce fill on each digit, turns red and shakes on wrong PIN
- **Async validation** — `onComplete` is `async`, safe for network calls, Keychain lookups, or local checks
- **Loading state** — keypad is replaced with a spinner while your async handler runs
- **Biometric button** — configurable Face ID / Touch ID shortcut; set `biometricLabel: nil` to hide
- **Haptic feedback** — light tap on digit press, error notification on wrong PIN, success notification on unlock
- **Success state** — lock icon animates to a checkmark on successful entry
- **Fully configurable** — PIN length, colors, title, subtitle, haptics, and obscured input via `PinEntryConfiguration`
- **iOS 16+, macOS 13+**

---

## Requirements

| Platform | Minimum |
|---|---|
| iOS | 16.0 |
| macOS | 13.0 |
| Swift | 5.9 |
| Xcode | 15.0 |

---

## Installation

### Swift Package Manager — Xcode

1. In Xcode, go to **File → Add Package Dependencies**
2. Paste the repository URL:
   ```
   https://github.com/kusalrajapaksha/PinEntryKit
   ```
3. Select **Up to Next Major Version** from `1.0.0`
4. Add `PinEntryKit` to your app target

### Swift Package Manager — `Package.swift`

```swift
dependencies: [
    .package(url: "https://github.com/kusalrajapaksha/PinEntryKit", from: "1.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: ["PinEntryKit"]
    )
]
```

---

## Usage

### Minimal

```swift
import PinEntryKit

struct ContentView: View {
    var body: some View {
        PinEntryView { pin in
            return pin == "123456"
        }
    }
}
```

### With navigation / state

```swift
import PinEntryKit

struct LockScreen: View {
    @State private var isUnlocked = false

    var body: some View {
        if isUnlocked {
            MainAppView()
        } else {
            PinEntryView { pin in
                let success = pin == "123456"
                if success { isUnlocked = true }
                return success
            }
        }
    }
}
```

### Async network or Keychain validation

```swift
PinEntryView { pin in
    return await MyAuthService.validate(pin: pin)
}
```

The keypad automatically shows a loading spinner while the handler runs and re-enables on completion.

### Full configuration

```swift
import PinEntryKit

PinEntryView(
    configuration: PinEntryConfiguration(
        pinLength: 6,
        accentColor: .mint,
        backgroundColor: Color(red: 0.08, green: 0.08, blue: 0.10),
        title: "Enter PIN",
        subtitle: "Use your 6-digit PIN to unlock",
        biometricLabel: "Face ID",  // pass nil to hide the button
        hapticsEnabled: true,
        obscureInput: true
    ),
    onBiometric: {
        authenticateWithFaceID()
    }
) { pin in
    return await MyAuthService.validate(pin: pin)
}
```

### Biometric authentication (LocalAuthentication)

```swift
import LocalAuthentication
import PinEntryKit

func authenticateWithBiometrics() {
    let context = LAContext()
    var error: NSError?

    guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
        return
    }

    context.evaluatePolicy(
        .deviceOwnerAuthenticationWithBiometrics,
        localizedReason: "Unlock with Face ID"
    ) { success, _ in
        DispatchQueue.main.async {
            if success { isUnlocked = true }
        }
    }
}
```

Pass `authenticateWithBiometrics` to `onBiometric:` and set `biometricLabel` to `"Face ID"` or `"Touch ID"` to match the device.

---

## Configuration Reference

All properties on `PinEntryConfiguration` have defaults, so you only need to set what you want to change.

| Property | Type | Default | Description |
|---|---|---|---|
| `pinLength` | `Int` | `6` | Number of PIN digits (dots and expected input length) |
| `accentColor` | `Color` | mint green | Color of filled dots, biometric button, and loading spinner |
| `backgroundColor` | `Color` | `#141517` | Full-screen background color |
| `title` | `String` | `"Enter PIN"` | Heading displayed above the dots |
| `subtitle` | `String` | `"Use your PIN to continue"` | Instruction text below the title; replaced by error message on failure |
| `biometricLabel` | `String?` | `"Face ID"` | Label on the biometric button. Pass `nil` to hide the button entirely |
| `hapticsEnabled` | `Bool` | `true` | Enables haptic feedback on digit press, error, and success |
| `obscureInput` | `Bool` | `true` | Show dots instead of the entered digits |

---

## File Structure

```
PinEntryKit/
├── Package.swift
├── README.md
├── Sources/
│   └── PinEntryKit/
│       ├── PinEntryKit.swift              ← public exports
│       ├── Models/
│       │   └── PinEntryConfiguration.swift   ← configuration struct
│       └── Views/
│           ├── PinEntryView.swift         ← main view & state logic
│           ├── PinDotsView.swift          ← animated dot row
│           └── KeypadView.swift           ← custom numeric keypad
└── Tests/
    └── PinEntryKitTests/
        └── PinEntryKitTests.swift
```

---

## Customisation Tips

**4-digit PIN:**
```swift
PinEntryConfiguration(pinLength: 4, title: "Enter Passcode")
```

**Light theme:**
```swift
PinEntryConfiguration(
    accentColor: Color(red: 0.20, green: 0.50, blue: 0.90),
    backgroundColor: Color(red: 0.97, green: 0.97, blue: 0.98)
)
```

**Hide biometric button:**
```swift
PinEntryConfiguration(biometricLabel: nil)
```

**Disable haptics (e.g. for testing):**
```swift
PinEntryConfiguration(hapticsEnabled: false)
```

---

## License

MIT License. See [LICENSE](LICENSE) for details.
