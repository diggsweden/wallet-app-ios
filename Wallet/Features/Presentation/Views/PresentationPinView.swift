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
      PinPromptView(
        title: "Godkänn och identifiera",
        subtitle: subtitle,
        submitLabel: "Dela",
        isLoading: isLoading,
        onSubmit: onPinEntered,
      )
      .padding(.horizontal, theme.horizontalPadding)
    }
  }

  private var subtitle: LocalizedStringResource {
    "Fyll i din pinkod för att dela \(sharedClaimCount) uppgifter med \(verifierName)."
  }
}
