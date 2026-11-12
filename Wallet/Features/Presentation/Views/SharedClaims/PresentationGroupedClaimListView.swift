// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import DesignSystem
import OpenId4VCInterface
import SwiftUI

struct PresentationGroupedClaimListView: View {
  let credentials: [CredentialUiModel]
  let icon: (CredentialUiModel) -> Image?

  @Environment(\.theme) private var theme

  init(
    credentials: [CredentialUiModel],
    icon: @escaping (CredentialUiModel) -> Image? = { _ in nil },
  ) {
    self.credentials = credentials
    self.icon = icon
  }

  var body: some View {
    VStack(alignment: .leading, spacing: Constants.groupSpacing) {
      ForEach(credentials, id: \.type) { credential in
        groupView(credential)
      }
    }
  }
}

private extension PresentationGroupedClaimListView {
  enum Constants {
    static let groupSpacing: CGFloat = 24
    static let titleSpacing: CGFloat = 12
    static let titleHorizontalPadding: CGFloat = 16
    static let listHorizontalPadding: CGFloat = 16
    static let listVerticalPadding: CGFloat = 6
    static let cornerRadius: CGFloat = 20
    static let borderWidth: CGFloat = 1
    static let iconSize: CGFloat = 26
    static let iconSpacing: CGFloat = 10
  }

  @ContentBuilder
  func groupView(_ credential: CredentialUiModel) -> some View {
    VStack(alignment: .leading, spacing: Constants.titleSpacing) {
      groupHeaderView(credential)
        .padding(.horizontal, Constants.titleHorizontalPadding)

      PresentationClaimListView(claims: credential.claims)
        .padding(.horizontal, Constants.listHorizontalPadding)
        .padding(.vertical, Constants.listVerticalPadding)
        .overlay {
          RoundedRectangle(cornerRadius: Constants.cornerRadius)
            .stroke(theme.colors.primaryVariant, lineWidth: Constants.borderWidth)
        }
    }
  }

  @ContentBuilder
  func groupHeaderView(_ credential: CredentialUiModel) -> some View {
    HStack(spacing: Constants.iconSpacing) {
      if let icon = icon(credential) {
        icon
          .resizable()
          .scaledToFit()
          .frame(width: Constants.iconSize, height: Constants.iconSize)
          .accessibilityHidden(true)
      }

      Text(credential.name ?? "Dokument")
        .textStyle(.h5)
        .accessibilityAddTraits(.isHeader)
    }
  }
}

#Preview {
  PresentationGroupedClaimListView(
    credentials: [
      CredentialUiModel(
        type: "urn:eudi:pid:1",
        name: "ID-uppgifter",
        claims: [
          ClaimUiModel(id: "given_name", displayName: "Förnamn", value: .string("Elin")),
          ClaimUiModel(id: "family_name", displayName: "Efternamn", value: .string("Andersson")),
          ClaimUiModel(id: "age_over_18", displayName: "Över 18 år", value: .bool(true)),
        ],
      ),
      CredentialUiModel(
        type: "urn:mdl",
        name: "Mobilt körkort",
        claims: [
          ClaimUiModel(id: "privileges", displayName: "Behörigheter", value: .string("B")),
          ClaimUiModel(
            id: "expiry_date",
            displayName: "Giltigt till",
            value: .date(Date(timeIntervalSince1970: 1_924_000_000)),
          ),
        ],
      ),
    ],
    icon: { credential in
      Image(systemName: credential.type == "urn:mdl" ? "car.side.fill" : "person.text.rectangle")
    },
  )
  .padding()
  .themed
}
