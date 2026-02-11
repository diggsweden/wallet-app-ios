// SPDX-FileCopyrightText: 2026 diggsweden/wallet-app-ios
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct PinDot: View {
  let filled: Bool
  let color: Color
  let size: CGFloat

  var body: some View {
    Circle()
      .fill(filled ? color : .clear)
      .stroke(filled ? .clear : color, lineWidth: 1)
      .frame(width: size, height: size)
      .phaseAnimator([true, false], trigger: filled) { view, phase in
        view
          .scaleEffect(phase ? 1 : 1.2)
          .blur(radius: phase ? 0 : 0.2)
      } animation: { _ in
        .spring(response: 0.18, dampingFraction: 0.9)
      }
  }
}
