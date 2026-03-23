// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct FullHeightScrollView<Content: View>: View {
  @ViewBuilder private let content: () -> Content
  @State private var minHeight: CGFloat = 0

  init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }

  var body: some View {
    ScrollView {
      content()
        .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .top)
    }
    .onGeometryChange(for: CGFloat.self) { proxy in
      proxy.size.height
    } action: {
      minHeight = $0
    }
  }
}
