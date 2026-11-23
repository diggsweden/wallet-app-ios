// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import DesignSystem
import SwiftUI
import UIComponents

struct PresentationPinView: View {
  @Environment(\.theme) private var theme

  let verifierName: String
  let sharedClaimCount: Int
  let isLoading: Bool
  let onPinEntered: (String) -> Void

  var body: some View {
    SoftEdgeScrollView(fillsHeight: true) {
      VStack(spacing: Constants.sectionSpacing) {
        VStack(spacing: Constants.textSpacing) {
          Image(systemName: "lock.fill")
            .font(.system(size: Constants.iconSize, weight: .semibold))
            .foregroundStyle(theme.colors.textInformation)
            .frame(
              width: Constants.iconContainerSize,
              height: Constants.iconContainerSize,
            )
            .background(
              theme.colors.textPrimary.opacity(Constants.iconBackgroundOpacity),
              in: Circle(),
            )
            .accessibilityHidden(true)
            .padding(.bottom, Constants.iconBottomPadding)

          Text("Godkänn och identifiera")
            .textStyle(.h1)
            .accessibilityAddTraits(.isHeader)

          Text("Fyll i din pinkod för att dela \(sharedClaimCount) uppgifter med \(verifierName).")
            .textStyle(.bodyLarge)
            .foregroundStyle(theme.colors.textInformation)
        }
        .multilineTextAlignment(.center)

        PinView(
          submitLabel: "Dela",
          isLoading: isLoading,
          onSubmit: onPinEntered,
        )
      }
      .padding(.horizontal, theme.horizontalPadding)
    }
  }
}

private extension PresentationPinView {
  enum Constants {
    static let sectionSpacing: CGFloat = 28
    static let textSpacing: CGFloat = 8
    static let iconSize: CGFloat = 22
    static let iconContainerSize: CGFloat = 56
    static let iconBackgroundOpacity: CGFloat = 0.05
    static let iconBottomPadding: CGFloat = 8
  }
}
