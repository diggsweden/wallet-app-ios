// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import DesignSystem
import SwiftUI
import UIComponents

struct PresentationReviewView: View {
  @Binding var optionalItems: [PresentationItem]
  @Environment(\.theme) private var theme

  let requiredItems: [PresentationItem]
  let verifierName: String
  let verifierPurpose: String?
  let onHeaderTap: () -> Void

  var body: some View {
    SoftEdgeScrollView(fillsHeight: true) {
      VStack(spacing: Constants.sectionSpacing) {
        PresentationReviewHeaderView(
          name: verifierName,
          purpose: verifierPurpose,
          onTap: onHeaderTap,
        )

        VStack(alignment: .leading, spacing: Constants.cardSpacing) {
          Text("Det här delas")
            .textStyle(.h3)
            .padding(.horizontal, Constants.sectionTitleHorizontalPadding)

          ForEach(requiredItems) { item in
            PresentationRequiredCardView(
              title: item.credentialUiModel.name ?? "Dokument",
              claims: item.credentialUiModel.claims,
            )
          }
        }

        if !optionalItems.isEmpty {
          Text("Valfria uppgifter:")
            .textStyle(.h3)
            .frame(maxWidth: .infinity, alignment: .leading)

          ForEach($optionalItems) { $item in
            SelectiveDisclosureView(
              isSelected: $item.isSelected,
              claims: item.credentialUiModel.claims,
            )
          }
        }
      }
      .padding(.horizontal, theme.horizontalPadding)
    }
  }
}

private extension PresentationReviewView {
  enum Constants {
    static let sectionSpacing: CGFloat = 28
    static let cardSpacing: CGFloat = 12
    static let sectionTitleHorizontalPadding: CGFloat = 16
  }
}
