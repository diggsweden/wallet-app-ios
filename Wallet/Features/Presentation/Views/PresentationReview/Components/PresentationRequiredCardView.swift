// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import DesignSystem
import SwiftUI

struct PresentationRequiredCardView: View {
  @Environment(\.theme) private var theme
  @State private var isExpanded = false

  let title: String
  let claims: [ClaimUiModel]
  let icon: Image?

  init(
    title: String,
    claims: [ClaimUiModel],
    icon: Image? = nil,
  ) {
    self.title = title
    self.claims = claims
    self.icon = icon
  }

  var body: some View {
    Button {
      withAnimation(.smooth) {
        isExpanded.toggle()
      }
    } label: {
      HStack(alignment: .top, spacing: Constants.contentSpacing) {
        if let icon {
          iconView(icon)
        }

        VStack(alignment: .leading, spacing: Constants.titleSpacing) {
          Text(title)
            .textStyle(.h5)

          claimsView
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        chevronView
      }
      .multilineTextAlignment(.leading)
      .padding(Constants.padding)
      .background(
        theme.colors.background,
        in: RoundedRectangle(cornerRadius: Constants.cornerRadius),
      )
      .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
      .overlay {
        RoundedRectangle(cornerRadius: Constants.cornerRadius)
          .stroke(theme.colors.primaryVariant, lineWidth: Constants.borderWidth)
      }
    }
    .buttonStyle(.plain)
    .accessibilityHint(accessibilityHint)
  }
}

private extension PresentationRequiredCardView {
  enum Constants {
    static let collapsedClaimCount = 4
    static let contentSpacing: CGFloat = 12
    static let titleSpacing: CGFloat = 4
    static let padding: CGFloat = 16
    static let cornerRadius: CGFloat = 20
    static let borderWidth: CGFloat = 1
    static let iconSize: CGFloat = 26
    static let chevronTopPadding: CGFloat = 4
    static let collapsedClaimsListPadding: CGFloat = 4
    static let chevronRotation: CGFloat = 180
  }

  var previewClaims: [ClaimUiModel] {
    Array(claims.prefix(Constants.collapsedClaimCount))
  }

  var hiddenClaimCount: Int {
    claims.count - previewClaims.count
  }

  var accessibilityHint: LocalizedStringKey {
    isExpanded ? "Visa färre uppgifter" : "Visa alla uppgifter"
  }

  @ContentBuilder
  var claimsView: some View {
    ZStack(alignment: .topLeading) {
      if isExpanded {
        PresentationClaimListView(claims: claims)
          .transition(.opacity)
      } else {
        collapsedClaimsView
          .transition(.opacity)
      }
    }
  }

  @ContentBuilder
  var collapsedClaimsView: some View {
    VStack(
      alignment: .leading,
      spacing: Constants.collapsedClaimsListPadding,
    ) {
      ForEach(previewClaims) { claim in
        if let displayName = claim.displayName {
          Text(displayName)
            .textStyle(.bodySmall)
            .foregroundStyle(theme.colors.textInformation)
        }
      }

      if hiddenClaimCount > .zero {
        Text("+ \(hiddenClaimCount) till")
          .textStyle(.labelLarge)
          .foregroundStyle(theme.colors.linkPrimary)
      }
    }
  }

  @ContentBuilder
  var chevronView: some View {
    Image(systemName: "chevron.down")
      .foregroundStyle(theme.colors.textInformation)
      .rotationEffect(.degrees(isExpanded ? Constants.chevronRotation : .zero))
      .padding(.top, Constants.chevronTopPadding)
      .accessibilityHidden(true)
  }

  @ContentBuilder
  func iconView(_ icon: Image) -> some View {
    icon
      .resizable()
      .scaledToFit()
      .frame(width: Constants.iconSize, height: Constants.iconSize)
      .accessibilityHidden(true)
  }
}

#Preview("Many claims") {
  PresentationRequiredCardView(
    title: "ID-uppgifter",
    claims: [
      "Förnamn", "Efternamn", "Födelsedatum", "Personnummer", "Födelseort",
      "Födelseland", "Kön", "Över 18 år", "Utfärdat", "Giltigt till",
    ]
    .map { ClaimUiModel(id: $0, displayName: $0, value: .string("Exempel")) },
    icon: Image(systemName: "person.text.rectangle"),
  )
  .padding()
  .themed
}

#Preview("Few claims") {
  PresentationRequiredCardView(
    title: "Mobilt körkort",
    claims: ["Porträtt", "Behörigheter", "Giltigt till"]
      .map { ClaimUiModel(id: $0, displayName: $0, value: .string("Exempel")) },
  )
  .padding()
  .themed
}
