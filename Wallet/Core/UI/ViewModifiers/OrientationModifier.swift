// SPDX-FileCopyrightText: 2026 diggsweden/wallet-app-ios
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

private struct OrientationModifier: ViewModifier {
  func body(content: Content) -> some View {
    GeometryReader { g in
      let isLandscape = g.size.width > g.size.height
      content
        .environment(\.orientation, isLandscape ? .landscape : .portrait)
    }
  }
}

extension View {
  var withOrientation: some View {
    modifier(OrientationModifier())
  }
}
