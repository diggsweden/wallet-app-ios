// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import DesignSystem
import SwiftUI

struct PresentationClaimListView: View {
  let claims: [ClaimUiModel]

  var body: some View {
    VStack(alignment: .leading, spacing: .zero) {
      ForEach(claims) { claim in
        PresentationClaimRowView(claim: claim)
          .padding(.vertical, Constants.rowVerticalPadding)
          .accessibilityElement(children: .combine)

        if claim.id != claims.last?.id {
          Rectangle()
            .fill(Color(uiColor: .separator))
            .frame(height: Constants.dividerHeight)
        }
      }
    }
  }
}

private extension PresentationClaimListView {
  enum Constants {
    static let rowVerticalPadding: CGFloat = 10
    static let dividerHeight: CGFloat = 1
  }
}

// swiftlint:disable:next closure_body_length
#Preview {
  PresentationClaimListView(
    claims: [
      ClaimUiModel(id: "given_name", displayName: "Förnamn", value: .string("Elin")),
      ClaimUiModel(id: "family_name", displayName: "Efternamn", value: .string("Andersson")),
      ClaimUiModel(
        id: "birthdate",
        displayName: "Födelsedatum",
        value: .date(Date(timeIntervalSince1970: 764_000_000)),
      ),
      ClaimUiModel(id: "age_over_18", displayName: "Över 18 år", value: .bool(true)),
      ClaimUiModel(
        id: "address",
        displayName: "Adress",
        value: .object(
          [
            ClaimUiModel(id: "address.country", displayName: "Land", value: .string("SE")),
            ClaimUiModel(id: "address.locality", displayName: "Ort", value: .string("Stockholm")),
            ClaimUiModel(
              id: "address.postal_code",
              displayName: "Postnummer",
              value: .string("113 51"),
            ),
            ClaimUiModel(
              id: "address.street_address",
              displayName: "Gatuadress",
              value: .string("Storgatan 12"),
            ),
          ]
        ),
      ),
    ]
  )
  .padding()
  .themed
}
