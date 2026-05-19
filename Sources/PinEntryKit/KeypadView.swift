import SwiftUI

struct KeypadView: View {
    let accentColor: Color
    let biometricLabel: String?
    let onDigit: (String) -> Void
    let onDelete: () -> Void
    let onBiometric: (() -> Void)?

    private let layout: [[KeypadKey]] = [
        [.digit("1"), .digit("2"), .digit("3")],
        [.digit("4"), .digit("5"), .digit("6")],
        [.digit("7"), .digit("8"), .digit("9")],
        [.special(.biometric), .digit("0"), .special(.delete)],
    ]

    var body: some View {
        VStack(spacing: 14) {
            ForEach(layout.indices, id: \.self) { row in
                HStack(spacing: 14) {
                    ForEach(layout[row].indices, id: \.self) { col in
                        let key = layout[row][col]
                        KeypadButtonView(
                            key: key,
                            accentColor: accentColor,
                            biometricLabel: biometricLabel
                        ) {
                            switch key {
                            case .digit(let d):
                                onDigit(d)
                            case .special(.delete):
                                onDelete()
                            case .special(.biometric):
                                onBiometric?()
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Key Model

enum SpecialKey { case delete, biometric }

enum KeypadKey {
    case digit(String)
    case special(SpecialKey)
}

// MARK: - Button

private struct KeypadButtonView: View {
    let key: KeypadKey
    let accentColor: Color
    let biometricLabel: String?
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.easeOut(duration: 0.1)) { isPressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.easeOut(duration: 0.12)) { isPressed = false }
            }
            action()
        }) {
            ZStack {
                buttonBackground
                buttonLabel
            }
            .frame(width: buttonSize, height: buttonSize)
            .scaleEffect(isPressed ? 0.91 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(.plain)
        .disabled(isHidden)
        .opacity(isHidden ? 0 : 1)
    }

    // MARK: Helpers

    private var buttonSize: CGFloat { 76 }

    private var isHidden: Bool {
        if case .special(.biometric) = key, biometricLabel == nil { return true }
        return false
    }

    @ViewBuilder
    private var buttonBackground: some View {
        switch key {
        case .digit:
            Circle()
                .fill(Color.white.opacity(isPressed ? 0.18 : 0.08))
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        case .special(.delete):
            Color.clear
        case .special(.biometric):
            Color.clear
        }
    }

    @ViewBuilder
    private var buttonLabel: some View {
        switch key {
        case .digit(let d):
            Text(d)
                .font(.system(size: 28, weight: .light, design: .rounded))
                .foregroundColor(.white)

        case .special(.delete):
            Image(systemName: "delete.left")
                .font(.system(size: 22, weight: .light))
                .foregroundColor(.white.opacity(0.7))

        case .special(.biometric):
            VStack(spacing: 4) {
                Image(systemName: biometricIcon)
                    .font(.system(size: 22, weight: .light))
                if let label = biometricLabel {
                    Text(label)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                }
            }
            .foregroundColor(accentColor.opacity(0.85))
        }
    }

    private var biometricIcon: String {
        guard let label = biometricLabel else { return "faceid" }
        return label.lowercased().contains("touch") ? "touchid" : "faceid"
    }
}
