// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

extension ErrorView.ViewModel {
  init(
    caughtError: CaughtError,
    imageReference: String = "phoneError",
    title: String = "Hoppsan! Nånting gick fel",
    subtitle: String = "Vi kunde inte visa innehållet just nu, försök gärna igen senare.",
    primaryButton: ErrorView.ButtonModel,
    secondaryButton: ErrorView.ButtonModel? = nil,
    linkButton: ErrorView.ButtonModel? = nil,
    onDismiss: (@Sendable () -> Void)? = nil,
  ) {
    self.init(
      imageReference: imageReference,
      title: title,
      subtitle: subtitle,
      primaryButton: primaryButton,
      secondaryButton: secondaryButton,
      linkButton: linkButton,
      onDismiss: onDismiss,
      errorInfo: ErrorInfo(from: caughtError, system: SystemInfoProvider.shared.snapshot()),
    )
  }
}
