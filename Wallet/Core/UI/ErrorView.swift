// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct ErrorView: View {
  let model: ErrorViewModel

  var body: some View {
    VStack(spacing: .zero) {
      Image(model.imageReference)
        .accessibilityHidden(true)
        .padding(.bottom, Constants.imageBottomPadding)

      titleSubtitleStackView
        .padding(.bottom, Constants.titleSubtitleStackViewBottomPadding)

      buttonStackView
    }
    .toolbar {
      if let onDismiss = model.onDismiss {
        ToolbarItem(placement: .topBarLeading) {
          Button {
            onDismiss()
          } label: {
            Image(systemName: "xmark")
              .accessibilityLabel("Stäng")
              .accessibilityHint("Använd knappen för att stänga felskärmen")
          }
        }
      }
    }
  }
}

private extension ErrorView {
  enum Constants {
    static let imageBottomPadding: CGFloat = 15
    static let titleSubtitleStackViewBottomPadding: CGFloat = 50
    static let titleSubtitleStackViewOuterSpacing: CGFloat = 7
    static let titleSubtitleStackViewInnerSpacing: CGFloat = 16
    static let buttonStackViewSpacing: CGFloat = 20
  }
}

private extension ErrorView {
  var titleSubtitleStackView: some View {
    VStack(alignment: .leading, spacing: Constants.titleSubtitleStackViewOuterSpacing) {
      VStack(alignment: .leading, spacing: Constants.titleSubtitleStackViewInnerSpacing) {
        Text(model.title)
          .textStyle(.h1)

        Text(model.subtitle)
          .textStyle(.body)
      }

      if let linkButton = model.linkButton {
        Button {
          linkButton.action()
        } label: {
          Text(linkButton.label)
            .textStyle(.bodySmall)
            .underline()
        }
        .accessibilityLabel(linkButton.label)
        .accessibilityHint(linkButton.accessibilityHint)
      }
    }
  }

  var buttonStackView: some View {
    VStack(spacing: Constants.buttonStackViewSpacing) {
      PrimaryButton(model.primaryButton.label) {
        model.primaryButton.action()
      }
      .accessibilityLabel(model.primaryButton.label)
      .accessibilityHint(model.primaryButton.accessibilityHint)

      if let secondaryButton = model.secondaryButton {
        SecondaryButton(secondaryButton.label) {
          secondaryButton.action()
        }
        .accessibilityLabel(secondaryButton.label)
        .accessibilityHint(secondaryButton.accessibilityHint)
      }
    }
  }
}

#Preview("Default") {
  ErrorView(model: .defaultPreview)
    .defaultScreenStyle
    .themed
}

#Preview("Default with onDismiss") {
  NavigationStack {
    ErrorView(model: .defaultPreview)
      .defaultScreenStyle
      .themed
  }
}

#Preview("Two Buttons") {
  ErrorView(
    model: .init(
      imageReference: "phoneError",
      title: "Hoppsan! Nånting gick fel",
      subtitle: "Vi kunde inte visa innehållet just nu, försök gärna igen senare.",
      primaryButton: .init(
        label: "Försök igen",
        accessibilityHint: "Använd knappen för att försöka igen",
        action: {}
      ),
      secondaryButton: .init(
        label: "Avbryt",
        accessibilityHint: "Använd knappen för att avbryta",
        action: {}
      ),
      linkButton: .init(
        label: "Få hjälp",
        accessibilityHint: "Använd knappen för att få mer hjälp",
        action: {}
      )
    )
  )
  .defaultScreenStyle
  .themed
}

struct ErrorViewModel: Sendable {
  let imageReference: String
  let title: String
  let subtitle: String
  let primaryButton: ButtonModel
  let secondaryButton: ButtonModel?
  let linkButton: ButtonModel?
  let onDismiss: (@Sendable () -> Void)?

  init(
    imageReference: String = "phoneError",
    title: String = "Hoppsan! Nånting gick fel",
    subtitle: String = "Vi kunde inte visa innehållet just nu, försök gärna igen senare.",
    primaryButton: ButtonModel,
    secondaryButton: ButtonModel? = nil,
    linkButton: ButtonModel? = nil,
    onDismiss: (@Sendable () -> Void)? = nil
  ) {
    self.imageReference = imageReference
    self.title = title
    self.subtitle = subtitle
    self.primaryButton = primaryButton
    self.secondaryButton = secondaryButton
    self.linkButton = linkButton
    self.onDismiss = onDismiss
  }

  struct ButtonModel: Sendable {
    let label: String
    let accessibilityHint: String
    let action: @Sendable () -> Void
  }

  fileprivate static var defaultPreview: Self {
    Self(
      imageReference: "phoneError",
      title: "Hoppsan! Nånting gick fel",
      subtitle: "Vi kunde inte visa innehållet just nu, försök gärna igen senare.",
      primaryButton: .init(
        label: "Försök igen",
        accessibilityHint: "Använd knappen för att försöka igen",
        action: {}
      ),
      linkButton: .init(
        label: "Få hjälp",
        accessibilityHint: "Använd knappen för att få mer hjälp",
        action: {}
      ),
      onDismiss: {}
    )
  }
}

extension ErrorViewModel.ButtonModel {
  init(
    label: String,
    accessibilityHint: String,
    asyncAction: (@Sendable () async -> Void)?
  ) {
    self.init(
      label: label,
      accessibilityHint: accessibilityHint,
      action: {
        Task {
          await asyncAction?()
        }
      }
    )
  }

  init(
    label: String,
    accessibilityHint: String,
    asyncThrowingAction: (@Sendable () async throws -> Void)?,
    onError: @escaping @Sendable () -> Void
  ) {
    self.init(
      label: label,
      accessibilityHint: accessibilityHint,
      action: {
        Task {
          do {
            try await asyncThrowingAction?()
          } catch {
            onError()
          }
        }
      }
    )
  }

  init(
    label: String,
    accessibilityHint: String,
    throwingAction: (@Sendable () throws -> Void)?,
    onError: @escaping @Sendable (Error) -> Void
  ) {
    self.init(
      label: label,
      accessibilityHint: accessibilityHint,
      action: {
        do {
          try throwingAction?()
        } catch {
          onError(error)
        }
      }
    )
  }
}
