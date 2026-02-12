// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

private struct ThemeKey: EnvironmentKey {
  static let defaultValue: Theme = .light
}

extension EnvironmentValues {
  var theme: Theme {
    get { self[ThemeKey.self] }
    set { self[ThemeKey.self] = newValue }
  }
}

extension View {
  func theme(_ theme: Theme) -> some View {
    environment(\.theme, theme)
  }
}
