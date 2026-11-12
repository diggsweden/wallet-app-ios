// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import DesignSystem
import SwiftUI

struct PresentationClaimListView: View {
  @Environment(\.theme) private var theme

  let claims: [ClaimUiModel]

  var body: some View {
    VStack(alignment: .leading, spacing: .zero) {
      ForEach(claims) { claim in
        claimRowView(claim)

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
    static let rowSpacing: CGFloat = 2
    static let rowVerticalPadding: CGFloat = 10
    static let imageHeight: CGFloat = 160
    static let brokenImageSize: CGFloat = 120
    static let dividerHeight: CGFloat = 1
  }

  @ContentBuilder
  func claimRowView(_ claim: ClaimUiModel) -> some View {
    VStack(alignment: .leading, spacing: Constants.rowSpacing) {
      if let displayName = claim.displayName {
        Text(displayName)
          .textStyle(.label)
          .foregroundStyle(theme.colors.onSurface)
      }

      valueView(claim.value)
    }
    .padding(.vertical, Constants.rowVerticalPadding)
    .frame(maxWidth: .infinity, alignment: .leading)
    .accessibilityElement(children: .combine)
  }

  @ContentBuilder
  func valueView(_ value: ClaimValue) -> some View {
    switch value {
      case let .imageData(data):
        imageView(data)

      case .null:
        Text(text(for: value))
          .textStyle(.bodyMedium)
          .foregroundStyle(theme.colors.textInformation)

      default:
        Text(text(for: value))
          .textStyle(.bodyMedium)
    }
  }

  @ContentBuilder
  func imageView(_ data: Data) -> some View {
    if let image = UIImage(data: data) {
      Image(uiImage: image)
        .resizable()
        .scaledToFit()
        .frame(height: Constants.imageHeight)
        .accessibilityHidden(true)
    } else {
      Image(systemName: "photo.trianglebadge.exclamationmark")
        .resizable()
        .scaledToFit()
        .frame(width: Constants.brokenImageSize, height: Constants.brokenImageSize)
        .accessibilityHidden(true)
    }
  }

  func text(for value: ClaimValue) -> String {
    switch value {
      case let .string(value):
        value

      case let .date(value):
        value.formatted(date: .long, time: .omitted)

      case let .int(value):
        value.formatted()

      case let .double(value):
        value.formatted()

      case let .bool(value):
        if value {
          String(localized: "Ja")
        } else {
          String(localized: "Nej")
        }

      case .null:
        String(localized: "Ingen uppgift")

      case .imageData:
        String(localized: "Bild")

      case let .array(items):
        items.map { item in text(for: item.value) }.joined(separator: ", ")

      case let .object(parts):
        parts
          .sorted { part, otherPart in
            addressOrder(of: part) < addressOrder(of: otherPart)
          }
          .map { part in text(for: part.value) }
          .joined(separator: ", ")
    }
  }

  func addressOrder(of part: ClaimUiModel) -> Int {
    let keyOrder = [
      "street_address", "house_number", "postal_code", "locality", "region", "country",
    ]
    let key = part.id.components(separatedBy: ".").last ?? part.id
    return keyOrder.firstIndex(of: key) ?? keyOrder.count
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
