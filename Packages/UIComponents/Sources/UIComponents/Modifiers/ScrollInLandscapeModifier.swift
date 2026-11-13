// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct ScrollInLandscapeModifier: ViewModifier {
  @Environment(\.orientation) private var orientation
  private let topContentPadding: CGFloat

  init(topContentPadding: CGFloat) {
    self.topContentPadding = topContentPadding
  }

  func body(content: Content) -> some View {
    if orientation.isLandscape {
      SoftEdgeScrollView(showsIndicators: false) {
        content
          .padding(.top, topContentPadding)
      }
    } else {
      content
    }
  }
}

extension View {
  public func scrollInLandscape(topContentPadding: CGFloat) -> some View {
    modifier(ScrollInLandscapeModifier(topContentPadding: topContentPadding))
  }
}
