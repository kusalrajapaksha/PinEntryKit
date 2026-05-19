//
//  PinEntryKit
//
//  Created by Kusal-Dev
//

import SwiftUI

/// A full-screen PIN entry view with a custom numeric keypad.
///
/// Usage:
/// ```swift
/// PinEntryView(configuration: .init()) { pin in
///     // validate pin
///     return pin == "123456"
/// }
/// ```
public struct PinEntryView: View {

    // MARK: - Public

    public let configuration: PinEntryConfiguration
    /// Called when the user completes PIN entry.
    /// Return `true` to dismiss / mark success, `false` to trigger error shake.
    public let onComplete: (String) async -> Bool
    /// Optional: called when user taps the biometric button.
    public var onBiometric: (() -> Void)?

    // MARK: - State

    @State private var digits: [String] = []
    @State private var shakeOffset: CGFloat = 0
    @State private var isError: Bool = false
    @State private var isSuccess: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""

    // MARK: - Init

    public init(
        configuration: PinEntryConfiguration = .init(),
        onBiometric: (() -> Void)? = nil,
        onComplete: @escaping (String) async -> Bool
    ) {
        self.configuration = configuration
        self.onBiometric = onBiometric
        self.onComplete = onComplete
    }

    // MARK: - Body

    public var body: some View {
        ZStack {
            // Background
            configuration.backgroundColor
                .ignoresSafeArea()

            // Subtle radial glow
            RadialGradient(
                colors: [
                    configuration.accentColor.opacity(0.12),
                    Color.clear
                ],
                center: .top,
                startRadius: 0,
                endRadius: 420
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Title
                VStack(spacing: 8) {
                    lockIcon

                    Text(configuration.title)
                        .font(.system(size: 26, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)

                    Text(errorMessage.isEmpty ? configuration.subtitle : errorMessage)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(
                            errorMessage.isEmpty
                                ? .white.opacity(0.45)
                                : .red.opacity(0.85)
                        )
                        .animation(.easeInOut(duration: 0.2), value: errorMessage)
                }
                .padding(.bottom, 44)

                // Dots
                PinDotsView(
                    pinLength: configuration.pinLength,
                    filledCount: digits.count,
                    accentColor: configuration.accentColor,
                    shakeOffset: shakeOffset,
                    isError: isError
                )
                .padding(.bottom, 48)

                // Keypad
                if isLoading {
                    ProgressView()
                        .tint(configuration.accentColor)
                        .scaleEffect(1.3)
                        .frame(height: keypadHeight)
                } else {
                    KeypadView(
                        accentColor: configuration.accentColor,
                        biometricLabel: configuration.biometricLabel,
                        onDigit: addDigit,
                        onDelete: deleteDigit,
                        onBiometric: onBiometric
                    )
                    .transition(.opacity)
                }

                Spacer()
            }
            .padding(.horizontal, 32)
        }
    }

    // MARK: - Helpers

    private var keypadHeight: CGFloat { 4 * 76 + 3 * 14 }

    @ViewBuilder
    private var lockIcon: some View {
        ZStack {
            Circle()
                .fill(configuration.accentColor.opacity(0.12))
                .frame(width: 64, height: 64)
            if #available(iOS 17.0, *) {
                Image(systemName: isSuccess ? "checkmark" : "lock.fill")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(isSuccess ? configuration.accentColor : .white.opacity(0.7))
                    .contentTransition(.symbolEffect(.replace))
            } else {
                // Fallback on earlier versions
                Image(systemName: isSuccess ? "checkmark" : "lock.fill")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(isSuccess ? configuration.accentColor : .white.opacity(0.7))
            }
        }
        .padding(.bottom, 6)
    }

    // MARK: - Actions

    private func addDigit(_ digit: String) {
        guard digits.count < configuration.pinLength, !isLoading else { return }

        if configuration.hapticsEnabled {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }

        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
            digits.append(digit)
            isError = false
            errorMessage = ""
        }

        if digits.count == configuration.pinLength {
            submitPin()
        }
    }

    private func deleteDigit() {
        guard !digits.isEmpty, !isLoading else { return }
        if configuration.hapticsEnabled {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
            digits.removeLast()
            isError = false
            errorMessage = ""
        }
    }

    private func submitPin() {
        let pin = digits.joined()
        isLoading = true

        Task {
            let success = await onComplete(pin)
            await MainActor.run {
                isLoading = false
                if success {
                    isSuccess = true
                    if configuration.hapticsEnabled {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }
                } else {
                    triggerError()
                }
            }
        }
    }

    private func triggerError() {
        if configuration.hapticsEnabled {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
        withAnimation { isError = true }
        errorMessage = configuration.errortitle
        shake()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            withAnimation {
                digits = []
                isError = false
            }
        }
    }

    private func shake() {
        let values: [CGFloat] = [0, -12, 12, -10, 10, -6, 6, -3, 3, 0]
        var delay = 0.0
        for value in values {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: 0.05)) {
                    shakeOffset = value
                }
            }
            delay += 0.05
        }
    }
}

// MARK: - Preview

#Preview {
    PinEntryView(
        configuration: PinEntryConfiguration(
            pinLength: 4,
            accentColor: Color(red: 0.38, green: 0.75, blue: 0.60),
            backgroundColor: Color.black,
            title: "Enter PIN",
            subtitle: "Use your 4-digit PIN to unlock",
            biometricLabel: "Face ID"
        )
    ) { pin in
        try? await Task.sleep(nanoseconds: 600_000_000)
        return pin == "1234"
    }
}
