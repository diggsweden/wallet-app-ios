// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import DesignSystem
import SwiftUI
import UIComponents

struct PresentationLoadingView: View {
  @Environment(\.theme) private var theme

  var body: some View {
    SoftEdgeScrollView {
      VStack(alignment: .center, spacing: Constants.parentStackSpacing) {
        ProgressView()

        VStack(spacing: Constants.headingStackSpacing) {
          Text("Kontrollerar begäran")
            .textStyle(.h5)
            .accessibilityAddTraits(.isHeader)

          Text("Plånboken kontrollerar mottagaren mot tillitsregistret.")
            .textStyle(.body)
            .foregroundStyle(theme.colors.textInformation)
        }
        .multilineTextAlignment(.center)
      }
      .padding(.horizontal, theme.horizontalPadding)
      .containerRelativeFrame(.vertical)
    }
    .scrollBounceBehavior(.basedOnSize)
  }
}

private extension PresentationLoadingView {
  enum Constants {
    static let parentStackSpacing: CGFloat = 24
    static let headingStackSpacing: CGFloat = 6
  }
}

#Preview {
  PresentationLoadingView()
    .themed
}
