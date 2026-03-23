// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct DefaultScreenStyleModifier: ViewModifier {
  @Environment(\.theme) private var theme
  @Environment(\.hasBottomSafeArea) private var hasBottomSafeArea

  private let minimumBottomPadding: CGFloat = 24

  func body(content: Content) -> some View {
    content
      .padding(.horizontal, theme.horizontalPadding)
      .safeAreaPadding(.bottom, hasBottomSafeArea ? 0 : minimumBottomPadding)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background {
        theme.colors.background.ignoresSafeArea()
      }
  }
}

extension View {
  var defaultScreenStyle: some View {
    modifier(DefaultScreenStyleModifier())
  }
}
