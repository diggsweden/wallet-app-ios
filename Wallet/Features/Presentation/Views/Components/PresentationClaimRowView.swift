// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import DesignSystem
import SwiftUI

struct PresentationClaimRowView: View {
  let claim: ClaimUiModel

  @Environment(\.theme) private var theme

  var body: some View {
    VStack(alignment: .leading, spacing: Constants.rowSpacing) {
      if let displayName = claim.displayName {
        Text(displayName)
          .textStyle(.label)
          .foregroundStyle(theme.colors.onSurface)
      }

      valueView
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

private extension PresentationClaimRowView {
  enum Constants {
    static let rowSpacing: CGFloat = 2
    static let objectSpacing: CGFloat = 8
    static let objectLeadingPadding: CGFloat = 12
    static let objectTopPadding: CGFloat = 6
    static let imageHeight: CGFloat = 160
    static let brokenImageSize: CGFloat = 120
  }

  @ContentBuilder
  var valueView: some View {
    switch claim.value {
      case let .imageData(data):
        imageView(data)

      case .null:
        Text(text(for: claim.value))
          .textStyle(.bodyMedium)
          .foregroundStyle(theme.colors.textInformation)

      case let .object(parts):
        VStack(alignment: .leading, spacing: Constants.objectSpacing) {
          ForEach(parts) { part in
            PresentationClaimRowView(claim: part)
          }
        }
        .padding(.leading, Constants.objectLeadingPadding)
        .padding(.top, Constants.objectTopPadding)
        .frame(maxWidth: .infinity, alignment: .leading)

      default:
        Text(text(for: claim.value))
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
        parts.map { part in text(for: part.value) }.joined(separator: ", ")
    }
  }
}
