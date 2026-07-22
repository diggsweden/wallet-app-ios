// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

extension View {
  @ViewBuilder
  func glassEffectIfPossible() -> some View {
    if #available(iOS 26.0, *) {
      self.glassEffect(
        .regular.interactive(),
        in: RoundedRectangle(cornerRadius: 12),
      )
    } else {
      self
        .background(
          .ultraThinMaterial,
          in: RoundedRectangle(cornerRadius: 12),
        )
    }
  }

  @ViewBuilder
  func lineHeightIfAvailable(multiple factor: CGFloat?) -> some View {
    if #available(iOS 26.0, *) {
      if let factor {
        self.lineHeight(.multiple(factor: factor))
      } else {
        self.lineHeight(nil)
      }
    } else {
      self
    }
  }

  func staticAnimation(setTo animation: Animation?) -> some View {
    self
      .transaction { t in
        t.animation = animation
      }
  }
}
