// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import DesignSystem
import SwiftUI

struct PresentationSharedClaimsButtonView: View {
  let claimCount: Int
  let action: () -> Void

  @Environment(\.theme) private var theme

  var body: some View {
    Button(action: action) {
      HStack(spacing: Constants.iconSpacing) {
        Text("\(claimCount) uppgifter delas")

        Image(systemName: "chevron.up")
          .imageScale(.small)
          .accessibilityHidden(true)
      }
      .textStyle(.labelLarge)
      .foregroundStyle(theme.colors.textPrimary)
      .padding(.horizontal, Constants.horizontalPadding)
      .frame(minHeight: Constants.minimumHeight)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .accessibilityHint("Visa alla uppgifter som delas")
  }
}

private extension PresentationSharedClaimsButtonView {
  enum Constants {
    static let iconSpacing: CGFloat = 8
    static let horizontalPadding: CGFloat = 16
    static let minimumHeight: CGFloat = 44
  }
}

#Preview {
  PresentationSharedClaimsButtonView(claimCount: 13, action: {})
    .themed
}
