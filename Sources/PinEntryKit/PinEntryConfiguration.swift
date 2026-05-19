//
//  PinEntryKit
//
//  Created by Kusal-Dev
//

import SwiftUI

/// Configuration for the PIN entry view.
public struct PinEntryConfiguration {
    /// Number of PIN digits (default: 6)
    public var pinLength: Int
    /// Accent color for dots and keys
    public var accentColor: Color
    /// Background color of the view
    public var backgroundColor: Color
    /// Title text shown above the dots
    public var title: String
    /// Subtitle / instruction text
    public var subtitle: String
    /// Errortitle / instruction text
    public var errortitle: String
    /// Whether to show biometric button (Face ID / Touch ID label)
    public var biometricLabel: String?
    /// Haptic feedback enabled
    public var hapticsEnabled: Bool
    /// Whether digits are obscured (dot) or shown
    public var obscureInput: Bool

    public init(
        pinLength: Int = 6,
        accentColor: Color = Color(red: 0.38, green: 0.75, blue: 0.60),
        backgroundColor: Color = Color(red: 0.08, green: 0.08, blue: 0.10),
        title: String = "Enter PIN",
        subtitle: String = "Use your PIN to continue",
        errortitle: String = "Incorrect PIN. Try again.",
        biometricLabel: String? = "Face ID",
        hapticsEnabled: Bool = true,
        obscureInput: Bool = true
    ) {
        self.pinLength = pinLength
        self.accentColor = accentColor
        self.backgroundColor = backgroundColor
        self.title = title
        self.subtitle = subtitle
        self.errortitle = errortitle
        self.biometricLabel = biometricLabel
        self.hapticsEnabled = hapticsEnabled
        self.obscureInput = obscureInput
    }
}
