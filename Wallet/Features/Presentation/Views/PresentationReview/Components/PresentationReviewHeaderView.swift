// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import DesignSystem
import SwiftUI

struct PresentationReviewHeaderView: View {
  let name: String
  let purpose: String?
  let logo: Image?
  let onTap: () -> Void

  @Environment(\.theme) private var theme

  init(
    name: String,
    purpose: String? = nil,
    logo: Image? = nil,
    onTap: @escaping () -> Void,
  ) {
    self.name = name
    self.purpose = purpose
    self.logo = logo
    self.onTap = onTap
  }

  var body: some View {
    Button(action: onTap) {
      HStack(spacing: Constants.contentSpacing) {
        VStack(alignment: .leading, spacing: Constants.purposeTopSpacing) {
          identityView

          if let purpose {
            purposeSectionView(purpose)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        Image(systemName: "chevron.right")
          .foregroundStyle(theme.colors.linkPrimary)
          .accessibilityHidden(true)
      }
      .multilineTextAlignment(.leading)
      .padding(Constants.padding)
      .background(
        theme.colors.primaryAccent,
        in: RoundedRectangle(cornerRadius: Constants.cornerRadius),
      )
    }
    .buttonStyle(.plain)
    .accessibilityHint("Visa verifiering")
  }
}

private extension PresentationReviewHeaderView {
  enum Constants {
    static let contentSpacing: CGFloat = 14
    static let nameStackSpacing: CGFloat = 3
    static let badgeSpacing: CGFloat = 6
    static let purposeTopSpacing: CGFloat = 16
    static let purposeStackSpacing: CGFloat = 2
    static let padding: CGFloat = 16
    static let cornerRadius: CGFloat = 20
    static let logoSize: CGFloat = 52
    static let logoCornerRadius: CGFloat = 15
    static let logoPadding: CGFloat = 8
    static let logoBorderWidth: CGFloat = 1
  }

  @ContentBuilder
  var identityView: some View {
    HStack(spacing: Constants.contentSpacing) {
      if let logo {
        logoTileView(logo)
      }

      VStack(alignment: .leading, spacing: Constants.nameStackSpacing) {
        Text(name)
          .textStyle(.h3)

        registeredBadgeView
      }
    }
  }

  @ContentBuilder
  var registeredBadgeView: some View {
    HStack(spacing: Constants.badgeSpacing) {
      Image(systemName: "checkmark.shield.fill")
        .accessibilityHidden(true)

      Text("Registrerad mottagare")
    }
    .textStyle(.labelLarge)
    .foregroundStyle(theme.colors.linkPrimary)
  }

  @ContentBuilder
  func purposeSectionView(_ purpose: String) -> some View {
    VStack(alignment: .leading, spacing: Constants.purposeStackSpacing) {
      Text("Varför de frågar")
        .textStyle(.label)
        .foregroundStyle(theme.colors.onSurface)

      Text(purpose)
        .textStyle(.body)
    }
  }

  @ContentBuilder
  func logoTileView(_ logo: Image) -> some View {
    logo
      .resizable()
      .scaledToFit()
      .padding(Constants.logoPadding)
      .frame(width: Constants.logoSize, height: Constants.logoSize)
      .background(
        theme.colors.background,
        in: RoundedRectangle(cornerRadius: Constants.logoCornerRadius),
      )
      .overlay {
        RoundedRectangle(cornerRadius: Constants.logoCornerRadius)
          .stroke(theme.colors.strokeDisabled, lineWidth: Constants.logoBorderWidth)
      }
      .accessibilityHidden(true)
  }
}

#Preview("Without logo") {
  PresentationReviewHeaderView(
    name: "Nordbil Hyrbilar AB",
    purpose: "Identitets- och körkortskontroll vid biluthyrning.",
    onTap: {},
  )
  .padding()
  .themed
}

#Preview("With logo") {
  PresentationReviewHeaderView(
    name: "Nordbil Hyrbilar AB",
    purpose: "Identitets- och körkortskontroll vid biluthyrning.",
    logo: Image(systemName: "car.side.fill"),
    onTap: {},
  )
  .padding()
  .themed
}

#Preview("Without purpose") {
  PresentationReviewHeaderView(name: "Nordbil Hyrbilar AB", onTap: {})
    .padding()
    .themed
}
