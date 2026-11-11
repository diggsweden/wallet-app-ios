// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import DesignSystem
import OpenId4VCInterface
import SwiftUI
import UIComponents

struct PresentationOptionalClaimListView: View {
  @Environment(\.theme) private var theme
  @Binding var items: [PresentationItem]

  let icon: (CredentialUiModel) -> Image?

  init(
    items: Binding<[PresentationItem]>,
    icon: @escaping (CredentialUiModel) -> Image? = { _ in nil },
  ) {
    _items = items
    self.icon = icon
  }

  var body: some View {
    VStack(alignment: .leading, spacing: Constants.sectionSpacing) {
      ForEach(credentialTypes, id: \.self) { type in
        sectionView(for: type)
      }
    }
  }
}

private extension PresentationOptionalClaimListView {
  enum Constants {
    static let headerSpacing: CGFloat = 8
    static let iconSize: CGFloat = 18
    static let sectionSpacing: CGFloat = 10
    static let headerTopPadding: CGFloat = 4
    static let headerBottomPadding: CGFloat = 6
  }

  var credentialTypes: [String] {
    var types: [String] = []
    for item in items where !types.contains(item.credentialUiModel.type) {
      types.append(item.credentialUiModel.type)
    }
    return types
  }

  @ContentBuilder
  func sectionView(for type: String) -> some View {
    let credential = items.first { item in
      item.credentialUiModel.type == type
    }?.credentialUiModel

    if let credential {
      VStack(alignment: .leading, spacing: .zero) {
        sectionHeaderView(credential)
          .padding(.top, Constants.headerTopPadding)
          .padding(.bottom, Constants.headerBottomPadding)

        ForEach($items) { $item in
          if item.credentialUiModel.type == type {
            Toggle(isOn: $item.isSelected) {
              PresentationClaimListView(claims: item.credentialUiModel.claims)
            }
            .toggleStyle(.checkbox)
          }
        }
      }
    }
  }

  @ContentBuilder
  func sectionHeaderView(_ credential: CredentialUiModel) -> some View {
    HStack(spacing: Constants.headerSpacing) {
      if let icon = icon(credential) {
        icon
          .resizable()
          .scaledToFit()
          .frame(width: Constants.iconSize, height: Constants.iconSize)
          .accessibilityHidden(true)
      }

      Text(credential.name ?? "Dokument")
        .textStyle(.h6)
        .foregroundStyle(theme.colors.textInformation)
        .accessibilityAddTraits(.isHeader)
    }
  }
}

// swiftlint:disable:next closure_body_length
#Preview {
  @Previewable @State var items = [
    PresentationItem(
      candidate: PresentationCandidate(
        id: "pid-address",
        required: false,
        credentialUiModel: CredentialUiModel(
          type: "urn:eudi:pid:1",
          name: "ID-uppgifter",
          claims: [
            ClaimUiModel(id: "address", displayName: "Adress", value: .string("Storgatan 12"))
          ],
        ),
      ),
      isSelected: true,
    ),
    PresentationItem(
      candidate: PresentationCandidate(
        id: "pid-nationality",
        required: false,
        credentialUiModel: CredentialUiModel(
          type: "urn:eudi:pid:1",
          name: "ID-uppgifter",
          claims: [
            ClaimUiModel(
              id: "nationality",
              displayName: "Medborgarskap",
              value: .string("Svenskt"),
            )
          ],
        ),
      ),
      isSelected: false,
    ),
    PresentationItem(
      candidate: PresentationCandidate(
        id: "mdl-issue-date",
        required: false,
        credentialUiModel: CredentialUiModel(
          type: "urn:mdl",
          name: "Mobilt körkort",
          claims: [
            ClaimUiModel(
              id: "issue_date",
              displayName: "Utfärdat",
              value: .date(Date(timeIntervalSince1970: 1_367_539_200)),
            )
          ],
        ),
      ),
      isSelected: false,
    ),
  ]

  PresentationOptionalClaimListView(items: $items)
    .padding()
    .themed
}
