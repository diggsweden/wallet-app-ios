// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import DesignSystem
import SwiftUI

public struct PinPromptView: View {
  let title: LocalizedStringResource?
  let subtitle: LocalizedStringResource
  let submitLabel: LocalizedStringResource
  let isLoading: Bool
  let onSubmit: (String) throws -> Void

  @Environment(\.theme) private var theme

  public init(
    title: LocalizedStringResource? = nil,
    subtitle: LocalizedStringResource,
    submitLabel: LocalizedStringResource,
    isLoading: Bool = false,
    onSubmit: @escaping (String) throws -> Void,
  ) {
    self.title = title
    self.subtitle = subtitle
    self.submitLabel = submitLabel
    self.isLoading = isLoading
    self.onSubmit = onSubmit
  }

  public var body: some View {
    VStack(spacing: Constants.sectionSpacing) {
      VStack(spacing: Constants.textSpacing) {
        Image(systemName: "lock.fill")
          .font(.system(size: Constants.iconSize, weight: .semibold))
          .foregroundStyle(theme.colors.textInformation)
          .frame(width: Constants.iconContainerSize, height: Constants.iconContainerSize)
          .background(
            theme.colors.textPrimary.opacity(Constants.iconBackgroundOpacity),
            in: Circle(),
          )
          .accessibilityHidden(true)
          .padding(.bottom, Constants.iconBottomPadding)

        if let title {
          Text(title)
            .textStyle(.h1)
            .accessibilityAddTraits(.isHeader)
        }

        Text(subtitle)
          .textStyle(.bodyLarge)
          .foregroundStyle(theme.colors.textInformation)
      }
      .multilineTextAlignment(.center)

      PinView(
        submitLabel: submitLabel,
        isLoading: isLoading,
        onSubmit: onSubmit,
      )
    }
  }
}

private extension PinPromptView {
  enum Constants {
    static let sectionSpacing: CGFloat = 28
    static let textSpacing: CGFloat = 8
    static let iconSize: CGFloat = 22
    static let iconContainerSize: CGFloat = 56
    static let iconBackgroundOpacity: CGFloat = 0.05
    static let iconBottomPadding: CGFloat = 8
  }
}

#Preview("With title") {
  PinPromptView(
    title: "Godkänn och identifiera",
    subtitle: "Fyll i din pinkod för att dela 4 uppgifter med Nordbil Hyrbilar AB.",
    submitLabel: "Dela",
  ) { _ in }
  .frame(maxWidth: .infinity, maxHeight: .infinity)
  .themed
  .withOrientation
  .withToast
}

#Preview("Without title") {
  PinPromptView(
    subtitle: "Skriv in din PIN-kod för att begära hämtning av dina personuppgifter",
    submitLabel: "Begär personuppgifter",
  ) { _ in }
  .frame(maxWidth: .infinity, maxHeight: .infinity)
  .themed
  .withOrientation
  .withToast
}
