// SPDX-FileCopyrightText: 2026 diggsweden/wallet-app-ios
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct ThemeModifier: ViewModifier {
  @Environment(\.colorScheme) private var scheme
  let defaultTextStyle: TextStyle = .body

  func body(content: Content) -> some View {
    let theme = (scheme == .dark) ? Theme.dark : Theme.light
    return
      content
      .environment(\.theme, theme)
      .environment(\.font, defaultTextStyle.metrics.font)
      .textStyle(defaultTextStyle)
      .background(theme.colors.background)
      .foregroundStyle(theme.colors.textPrimary)
  }
}

extension View {
  var themed: some View { modifier(ThemeModifier()) }
}
