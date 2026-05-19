//
//  PinEntryKit
//
//  Created by Kusal-Dev
//

import SwiftUI

struct PinDotsView: View {
    let pinLength: Int
    let filledCount: Int
    let accentColor: Color
    let shakeOffset: CGFloat
    let isError: Bool

    var body: some View {
        HStack(spacing: 18) {
            ForEach(0..<pinLength, id: \.self) { index in
                DotView(
                    filled: index < filledCount,
                    accentColor: accentColor,
                    isError: isError
                )
            }
        }
        .offset(x: shakeOffset)
    }
}

private struct DotView: View {
    let filled: Bool
    let accentColor: Color
    let isError: Bool

    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    filled
                        ? (isError ? Color.red.opacity(0.6) : accentColor.opacity(0.5))
                        : Color.white.opacity(0.15),
                    lineWidth: 1.5
                )
                .frame(width: 18, height: 18)

            if filled {
                Circle()
                    .fill(isError ? Color.red : accentColor)
                    .frame(width: 18, height: 18)
                    .scaleEffect(scale)
//                    .shadow(color: (isError ? Color.red : accentColor).opacity(0.7), radius: 4)
            }
        }
        .frame(width: 18, height: 18)
        .onChange(of: filled) { newValue in
            if newValue {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
                    scale = 1.3
                }
                withAnimation(.spring(response: 0.25, dampingFraction: 0.5).delay(0.1)) {
                    scale = 1.0
                }
            }
        }
    }
}
    
