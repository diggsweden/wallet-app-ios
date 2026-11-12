// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import DesignSystem
import OpenId4VCInterface
import SwiftUI
import UIComponents

struct PresentationSharedClaimsView: View {
  let credentials: [CredentialUiModel]
  let verifierName: String
  let hasBeenShared: Bool
  let icon: (CredentialUiModel) -> Image?

  @Environment(\.theme) private var theme

  init(
    credentials: [CredentialUiModel],
    verifierName: String,
    hasBeenShared: Bool = false,
    icon: @escaping (CredentialUiModel) -> Image? = { _ in nil },
  ) {
    self.credentials = credentials
    self.verifierName = verifierName
    self.hasBeenShared = hasBeenShared
    self.icon = icon
  }

  var body: some View {
    SoftEdgeScrollView {
      VStack(spacing: Constants.sectionSpacing) {
        headerView

        PresentationGroupedClaimListView(
          credentials: credentials,
          icon: icon,
        )
      }
      .padding(.horizontal, Constants.horizontalPadding)
      .padding(.top, Constants.topPadding)
      .padding(.bottom, Constants.bottomPadding)
    }
  }
}

private extension PresentationSharedClaimsView {
  enum Constants {
    static let sectionSpacing: CGFloat = 24
    static let headerSpacing: CGFloat = 6
    static let horizontalPadding: CGFloat = 16
    static let subtitleHorizontalPadding: CGFloat = 16
    static let topPadding: CGFloat = 16
    static let bottomPadding: CGFloat = 48
  }

  var claimCount: Int {
    credentials.flatMap(\.claims).count
  }

  var title: LocalizedStringKey {
    hasBeenShared ? "Det här delades" : "Det här delas"
  }

  var subtitle: LocalizedStringKey {
    hasBeenShared
      ? "\(claimCount) uppgifter delades med \(verifierName)"
      : "\(claimCount) uppgifter delas med \(verifierName)"
  }

  @ContentBuilder
  var headerView: some View {
    VStack(spacing: Constants.headerSpacing) {
      Text(title)
        .textStyle(.h2)
        .accessibilityAddTraits(.isHeader)

      Text(subtitle)
        .textStyle(.body)
        .foregroundStyle(theme.colors.textInformation)
        .padding(.horizontal, Constants.subtitleHorizontalPadding)
    }
    .multilineTextAlignment(.center)
  }
}

#Preview("Sharing") {
  PresentationSharedClaimsView(
    credentials: [
      CredentialUiModel(
        type: "urn:eudi:pid:1",
        name: "ID-uppgifter",
        claims: [
          ClaimUiModel(id: "given_name", displayName: "Förnamn", value: .string("Elin")),
          ClaimUiModel(id: "family_name", displayName: "Efternamn", value: .string("Andersson")),
          ClaimUiModel(id: "age_over_18", displayName: "Över 18 år", value: .bool(true)),
        ],
      )
    ],
    verifierName: "Nordbil Hyrbilar AB",
  )
  .themed
}

#Preview("Shared") {
  PresentationSharedClaimsView(
    credentials: [
      CredentialUiModel(
        type: "urn:eudi:pid:1",
        name: "ID-uppgifter",
        claims: [
          ClaimUiModel(id: "given_name", displayName: "Förnamn", value: .string("Elin"))
        ],
      )
    ],
    verifierName: "Nordbil Hyrbilar AB",
    hasBeenShared: true,
  )
  .themed
}
