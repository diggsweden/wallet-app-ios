// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct ClaimView: View {
  let claim: ClaimUiModel
  var labelStyle: TextStyle = .h5
  @Environment(\.theme) private var theme

  var body: some View {
    VStack(alignment: .leading, spacing: 5) {
      if let displayName = claim.displayName {
        Text("\(displayName):")
          .textStyle(labelStyle)
      }
      claimContent
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  @ViewBuilder
  private var claimContent: some View {
    switch claim.value {
      case .string(let value):
        Text(value)

      case .date(let value):
        Text(value.formatted(date: .long, time: .omitted))

      case .int(let value):
        Text(value.formatted())

      case .double(let value):
        Text(value.formatted())

      case .bool(let value):
        Label(
          value ? "Ja" : "Nej",
          systemImage: value ? "checkmark.circle.fill" : "xmark.circle.fill"
        )
        .foregroundStyle(value ? theme.colors.successInverse : theme.colors.errorInverse)

      case .null:
        Text("Ingen uppgift")
          .foregroundStyle(.secondary)

      case .array(let items):
        VStack(alignment: .leading, spacing: 4) {
          ForEach(items) { item in
            HStack(alignment: .top, spacing: 6) {
              Text("•")
              Self(claim: item)
            }
          }
        }

      case .object(let claims):
        VStack(alignment: .leading, spacing: 12) {
          ForEach(claims) { child in
            Self(claim: child, labelStyle: .h6)
          }
        }
        .padding(.leading, 12)
        .padding(.top, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

// swiftlint:disable:next closure_body_length
#Preview {
  let claims: [ClaimUiModel] = [
    ClaimUiModel(id: "name", displayName: "Namn", value: .string("Anna Andersson")),
    ClaimUiModel(
      id: "birth_date",
      displayName: "Födelsedatum",
      value: .date(Date(timeIntervalSince1970: 631_152_000))
    ),
    ClaimUiModel(id: "verified", displayName: "Verifierad", value: .bool(true)),
    ClaimUiModel(id: "int", displayName: "Integer", value: .int(42)),
    ClaimUiModel(id: "double", displayName: "Double", value: .double(2.42)),
    ClaimUiModel(
      id: "nationalities",
      displayName: "Nationaliteter",
      value: .array([
        ClaimUiModel(id: "nationalities.0", displayName: nil, value: .string("Svensk")),
        ClaimUiModel(id: "nationalities.1", displayName: nil, value: .string("Norsk")),
      ])
    ),
    ClaimUiModel(
      id: "address",
      displayName: "Adress",
      value: .object([
        ClaimUiModel(id: "street", displayName: "Gatuadress", value: .string("Kungsgatan 1")),
        ClaimUiModel(id: "city", displayName: "Stad", value: .string("Stockholm")),
      ])
    ),
  ]

  ScrollView {
    VStack(spacing: 26) {
      ForEach(claims) { claim in
        ClaimView(claim: claim)
      }
    }
    .padding()
  }
  .themed
}
