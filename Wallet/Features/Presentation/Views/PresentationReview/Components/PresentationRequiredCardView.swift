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
      guard isExpandable else {
        return
      }

      withAnimation {
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

          claimListView
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        if isExpandable {
          chevronView
        }
      }
      .multilineTextAlignment(.leading)
      .padding(Constants.padding)
      .background(
        theme.colors.background,
        in: RoundedRectangle(cornerRadius: Constants.cornerRadius),
      )
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

  var displayedClaims: [ClaimUiModel] {
    claims.flatMap { claim in
      guard case let .object(children) = claim.value, !children.isEmpty else {
        return [claim]
      }
      return children
    }
  }

  var isExpandable: Bool {
    displayedClaims.count > Constants.collapsedClaimCount
  }

  var visibleClaims: [ClaimUiModel] {
    isExpanded ? displayedClaims : Array(displayedClaims.prefix(Constants.collapsedClaimCount))
  }

  var hiddenClaimCount: Int {
    displayedClaims.count - visibleClaims.count
  }

  var accessibilityHint: LocalizedStringKey {
    guard isExpandable else {
      return ""
    }
    return isExpanded ? "Visa färre uppgifter" : "Visa alla uppgifter"
  }

  @ContentBuilder
  var claimListView: some View {
    VStack(
      alignment: .leading,
      spacing: Constants.collapsedClaimsListPadding,
    ) {
      ForEach(visibleClaims) { claim in
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

#Preview("Expandable") {
  PresentationRequiredCardView(
    title: "ID-uppgifter",
    claims: [
      "Förnamn", "Efternamn", "Födelsedatum", "Personnummer", "Födelseort",
      "Födelseland", "Kön", "Över 18 år", "Utfärdat", "Giltigt till",
    ]
    .map { ClaimUiModel(id: $0, displayName: $0, value: .null) },
    icon: Image(systemName: "person.text.rectangle"),
  )
  .padding()
  .themed
}

#Preview("Not expandable") {
  PresentationRequiredCardView(
    title: "Mobilt körkort",
    claims: ["Porträtt", "Behörigheter", "Giltigt till"]
      .map { ClaimUiModel(id: $0, displayName: $0, value: .null) },
  )
  .padding()
  .themed
}
