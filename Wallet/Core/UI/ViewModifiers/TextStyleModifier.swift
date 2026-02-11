// SPDX-FileCopyrightText: 2026 diggsweden/wallet-app-ios
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct TextStyleModifier: ViewModifier {
  let textStyle: TextStyle

  func body(content: Content) -> some View {
    let metrics = textStyle.metrics

    content
      .font(metrics.font)
      .lineHeightIfAvailable(multiple: metrics.lineHeightFactor)
  }
}

extension View {
  func textStyle(_ textStyle: TextStyle) -> some View {
    modifier(TextStyleModifier(textStyle: textStyle))
  }
}
