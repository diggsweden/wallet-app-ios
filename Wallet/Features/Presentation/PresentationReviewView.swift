// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct PresentationReviewView: View {
  let requiredItems: [PresentationItem]
  @Binding var optionalItems: [PresentationItem]
  let onConfirm: () -> Void

  var body: some View {
    FullHeightScrollView {
      VStack(spacing: 30) {
        Text("Dela uppgifter")
          .textStyle(.h1)

        ForEach(requiredItems) { item in
          CredentialView(title: "Uppgifter som delas:", claims: item.claims)
        }

        if !optionalItems.isEmpty {
          Text("Valfria uppgifter:")
            .textStyle(.h3)
            .frame(maxWidth: .infinity, alignment: .leading)

          ForEach($optionalItems) { $item in
            SelectiveDisclosureView(isSelected: $item.isSelected, claims: item.claims)
          }
        }

        Spacer()

        PrimaryButton("Dela", icon: "paperplane") {
          onConfirm()
        }
      }
    }
  }
}
