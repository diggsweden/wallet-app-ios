// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

extension ErrorView {
  struct ViewModel: Sendable {
    let imageReference: String
    let title: String
    let subtitle: String
    let primaryButton: ButtonModel
    let secondaryButton: ButtonModel?
    let linkButton: ButtonModel?
    let onDismiss: (@Sendable () -> Void)?
    let errorInfo: ErrorInfo

    init(
      imageReference: String = "phoneError",
      title: String = "Hoppsan! Nånting gick fel",
      subtitle: String = "Vi kunde inte visa innehållet just nu, försök gärna igen senare.",
      primaryButton: ButtonModel,
      secondaryButton: ButtonModel? = nil,
      linkButton: ButtonModel? = nil,
      onDismiss: (@Sendable () -> Void)? = nil,
      errorInfo: ErrorInfo = .mock,
    ) {
      self.imageReference = imageReference
      self.title = title
      self.subtitle = subtitle
      self.primaryButton = primaryButton
      self.secondaryButton = secondaryButton
      self.linkButton = linkButton
      self.onDismiss = onDismiss
      self.errorInfo = errorInfo
    }
  }

  struct ButtonModel: Sendable {
    let label: String
    let accessibilityHint: String
    let action: @Sendable () -> Void
  }
}

extension ErrorView.ButtonModel {
  init(
    label: String,
    accessibilityHint: String,
    asyncAction: (@Sendable () async -> Void)?,
  ) {
    self.init(
      label: label,
      accessibilityHint: accessibilityHint,
      action: {
        Task {
          await asyncAction?()
        }
      },
    )
  }

  init(
    label: String,
    accessibilityHint: String,
    asyncThrowingAction: (@Sendable () async throws -> Void)?,
    onError: @escaping @Sendable () -> Void,
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
      },
    )
  }

  init(
    label: String,
    accessibilityHint: String,
    throwingAction: (@Sendable () throws -> Void)?,
    onError: @escaping @Sendable (Error) -> Void,
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
      },
    )
  }
}

extension ErrorView.ViewModel {
  static var defaultPreview: Self {
    Self(
      imageReference: "phoneError",
      title: "Hoppsan! Nånting gick fel",
      subtitle: "Vi kunde inte visa innehållet just nu, försök gärna igen senare.",
      primaryButton: .init(
        label: "Försök igen",
        accessibilityHint: "Använd knappen för att försöka igen",
        action: {},
      ),
      linkButton: .init(
        label: "Få hjälp",
        accessibilityHint: "Använd knappen för att få mer hjälp",
        action: {},
      ),
      onDismiss: {},
    )
  }
}
