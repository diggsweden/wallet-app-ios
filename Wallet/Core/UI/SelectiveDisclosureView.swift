// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct SelectiveDisclosureView: View {
  @Binding var isSelected: Bool
  let claims: [ClaimUiModel]

  var body: some View {
    Button {
      isSelected.toggle()
    } label: {
      HStack(alignment: .top, spacing: 10) {
        Checkbox(isOn: $isSelected)
          .padding(.top, 2)
          .allowsHitTesting(false)
        VStack(alignment: .leading, spacing: 26) {
          ForEach(claims) { claim in
            ClaimView(claim: claim)
          }
        }
      }
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  @Previewable @State var isSelected = false

  SelectiveDisclosureView(
    isSelected: $isSelected,
    claims: [
      ClaimUiModel(id: "birth_date", displayName: "Födelsedatum", value: .string("1955-04-12")),
      ClaimUiModel(id: "age", displayName: "Ålder", value: .int(70)),
    ]
  )
  .padding()
  .themed
}
