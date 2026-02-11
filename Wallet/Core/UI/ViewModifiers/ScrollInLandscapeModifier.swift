// SPDX-FileCopyrightText: 2026 diggsweden/wallet-app-ios
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct ScrollInLandscapeModifier: ViewModifier {
  @Environment(\.orientation) private var orientation

  func body(content: Content) -> some View {
    if orientation.isLandscape {
      ScrollView { content }
        .scrollIndicators(.hidden)
    } else {
      content
    }
  }
}

extension View {
  var scrollInLandscape: some View { modifier(ScrollInLandscapeModifier()) }
}
