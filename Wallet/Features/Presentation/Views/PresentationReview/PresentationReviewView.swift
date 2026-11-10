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
  let onConfirm: () -> Void

  var body: some View {
    SoftEdgeScrollView(fillsHeight: true) {
      VStack(spacing: 30) {
        PresentationReviewHeaderView(
          name: verifierName,
          purpose: verifierPurpose,
          onTap: {},  // TODO: Sheet
        )

        ForEach(requiredItems) { item in
          CredentialView(
            title: "Uppgifter som delas:",
            claims: item.credentialUiModel.claims,
          )
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

        Spacer()

        PrimaryButton("Dela", icon: "paperplane") {
          onConfirm()
        }
      }
      .padding(.horizontal, theme.horizontalPadding)
    }
  }
}
