// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct SoftEdgeScrollView<Content: View>: View {
  private let showsIndicators: Bool
  private let fillsHeight: Bool
  private let content: Content
  @State private var minHeight: CGFloat = 0

  init(
    showsIndicators: Bool = true,
    fillsHeight: Bool = false,
    @ViewBuilder content: () -> Content,
  ) {
    self.showsIndicators = showsIndicators
    self.fillsHeight = fillsHeight
    self.content = content()
  }

  var body: some View {
    if fillsHeight {
      ScrollView(.vertical, showsIndicators: showsIndicators) {
        content
          .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .top)
      }
      .onGeometryChange(for: CGFloat.self) { proxy in
        proxy.size.height
      } action: { newHeight in
        minHeight = newHeight
      }
      .softScrollEdgeEffectIfPossible(for: .all)
    } else {
      ScrollView(.vertical, showsIndicators: showsIndicators) {
        content
      }
      .softScrollEdgeEffectIfPossible(for: .all)
    }
  }
}
