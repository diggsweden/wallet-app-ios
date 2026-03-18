// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct CredentialView: View {
  let claims: [ClaimUiModel]
  @Environment(\.theme) private var theme

  var body: some View {
    let shape = RoundedRectangle(cornerRadius: theme.cornerRadius)

    VStack(spacing: 26) {
      ForEach(claims) { claim in
        ClaimView(claim: claim)
      }
    }
    .padding(20)
    .background(theme.colors.backgroundPage, in: shape)
    .overlay(
      shape.stroke(theme.colors.stroke, lineWidth: 1)
    )
    .clipShape(shape)
  }
}

#Preview {
  let claims: [ClaimUiModel] = [
    ClaimUiModel(id: "name", displayName: "Namn", value: .string("Anna Andersson")),
    ClaimUiModel(
      id: "birth_date",
      displayName: "Födelsedatum",
      value: .date(Date(timeIntervalSince1970: 631_152_000))
    ),
    ClaimUiModel(id: "age", displayName: "Ålder", value: .int(34)),
    ClaimUiModel(id: "verified", displayName: "Verifierad", value: .bool(true)),
    ClaimUiModel(
      id: "nationalities",
      displayName: "Nationaliteter",
      value: .array([
        ClaimUiModel(id: "nationalities.locality", displayName: nil, value: .string("SE"))
      ])
    ),
    ClaimUiModel(
      id: "address",
      displayName: "Adress",
      value: .object([
        ClaimUiModel(
          id: "street_address",
          displayName: "Gatuadress",
          value: .string("Kungsgatan 1")
        ),
        ClaimUiModel(id: "city", displayName: "Stad", value: .string("Stockholm")),
        ClaimUiModel(id: "postal_code", displayName: "Postnummer", value: .string("111 22")),
      ])
    ),
  ]

  ScrollView {
    CredentialView(claims: claims)
  }
  .padding()
  .themed
}
