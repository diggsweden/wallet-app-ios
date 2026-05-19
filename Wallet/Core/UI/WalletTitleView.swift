// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct WalletTitleView: View {
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    VStack(spacing: 14) {
      Text("Plånboken")
        .font(.custom("Ubuntu-Medium", size: 40, relativeTo: .largeTitle))
        .lineHeightIfAvailable(multiple: 1.2)
      Text("Din data, ditt val")
        .font(.custom("Ubuntu-Medium", size: 24, relativeTo: .title))
    }
    .foregroundStyle(titleColor)
  }
}

private extension WalletTitleView {
  var titleColor: Color {
    colorScheme == .dark ? BrandColors.brown.25 : BrandColors.brown.100
  }
}

#Preview {
  WalletTitleView()
}
