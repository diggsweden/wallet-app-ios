// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import DesignSystem
import OpenId4VCInterface
import SwiftUI

struct PresentationOptionalCardView: View {
  @Environment(\.theme) private var theme
  @State private var isExpanded = false
  @Binding var items: [PresentationItem]

  var body: some View {
    VStack(alignment: .leading, spacing: .zero) {
      Button {
        withAnimation(.smooth) {
          isExpanded.toggle()
        }
      } label: {
        headerView
      }
      .buttonStyle(.plain)
      .accessibilityHint(isExpanded ? "Dölj valfria uppgifter" : "Visa valfria uppgifter")

      if isExpanded {
        PresentationOptionalClaimListView(items: $items)
          .padding(.horizontal, Constants.padding)
          .padding(.bottom, Constants.expandedBottomPadding)
          .transition(.opacity)
      }
    }
    .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
    .overlay {
      RoundedRectangle(cornerRadius: Constants.cornerRadius)
        .stroke(
          theme.colors.borderInteractive,
          style: StrokeStyle(
            lineWidth: Constants.borderWidth,
            dash: [Constants.dashLength, Constants.dashGap],
          ),
        )
    }
  }
}

private extension PresentationOptionalCardView {
  var selectedItems: [PresentationItem] {
    items.filter(\.isSelected)
  }

  var previewItems: [PresentationItem] {
    Array(selectedItems.prefix(Constants.collapsedTitleCount))
  }

  var hiddenItemCount: Int {
    selectedItems.count - previewItems.count
  }

  func title(for item: PresentationItem) -> String {
    item.credentialUiModel.claims
      .compactMap(\.displayName)
      .joined(separator: ", ")
  }

  @ContentBuilder
  var headerView: some View {
    HStack(alignment: .top, spacing: Constants.contentSpacing) {
      Image(systemName: "plus.circle.fill")
        .font(.system(size: Constants.iconSize))
        .symbolRenderingMode(.palette)
        .foregroundStyle(theme.colors.textPrimary, theme.colors.backgroundDisabled)
        .accessibilityHidden(true)

      VStack(alignment: .leading, spacing: Constants.titleSpacing) {
        Text("Valfria uppgifter")
          .textStyle(.h5)

        if !isExpanded {
          selectionView
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      Text("\(selectedItems.count) av \(items.count)")
        .textStyle(.bodySmall)
        .foregroundStyle(theme.colors.textInformation)

      Image(systemName: "chevron.down")
        .foregroundStyle(theme.colors.textInformation)
        .rotationEffect(.degrees(isExpanded ? Constants.chevronRotation : .zero))
        .padding(.top, Constants.chevronTopPadding)
        .accessibilityHidden(true)
    }
    .multilineTextAlignment(.leading)
    .padding(Constants.padding)
    .contentShape(Rectangle())
  }

  @ContentBuilder
  var selectionView: some View {
    if selectedItems.isEmpty {
      Text("Inga valda")
        .textStyle(.bodySmall)
        .foregroundStyle(theme.colors.textInformation)
    } else {
      VStack(alignment: .leading, spacing: Constants.collapsedTitlesSpacing) {
        ForEach(previewItems) { item in
          Text(title(for: item))
            .textStyle(.bodySmall)
            .foregroundStyle(theme.colors.textInformation)
        }

        if hiddenItemCount > .zero {
          Text("+ \(hiddenItemCount) till")
            .textStyle(.labelLarge)
            .foregroundStyle(theme.colors.linkPrimary)
        }
      }
    }
  }
}

private enum Constants {
  static let collapsedTitleCount = 4
  static let contentSpacing: CGFloat = 12
  static let titleSpacing: CGFloat = 4
  static let collapsedTitlesSpacing: CGFloat = 4
  static let padding: CGFloat = 16
  static let expandedBottomPadding: CGFloat = 10
  static let cornerRadius: CGFloat = 20
  static let borderWidth: CGFloat = 1.5
  static let dashLength: CGFloat = 4
  static let dashGap: CGFloat = 4
  static let iconSize: CGFloat = 28
  static let chevronTopPadding: CGFloat = 4
  static let chevronRotation: CGFloat = 180
}

#Preview("Nothing selected") {
  @Previewable @State var items = ["Adress", "Medborgarskap", "Utfärdat"]
    .map { name in
      PresentationItem(
        candidate: PresentationCandidate(
          id: name,
          required: false,
          credentialUiModel: CredentialUiModel(
            type: "urn:eudi:pid:1",
            name: "ID-uppgifter",
            claims: [ClaimUiModel(id: name, displayName: name, value: .string("Exempel"))],
          ),
        ),
        isSelected: false,
      )
    }

  PresentationOptionalCardView(items: $items)
    .padding()
    .themed
}
