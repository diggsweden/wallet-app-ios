// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import DesignSystem
import SwiftUI

struct WalletErrorView: View {
  let title: String
  let message: String
  let onRetry: () -> Void
  var onAbort: (() -> Void)?

  @Environment(\.theme) private var theme

  var body: some View {
    VStack(spacing: 30) {
      Text(title)
        .textStyle(.h1)
        .padding(.top, 50)

      Image(systemName: "exclamationmark.triangle.fill")
        .font(.system(size: 64))
        .foregroundStyle(theme.colors.errorInverse)
        .accessibilityHidden(true)

      Text(message)
        .textStyle(.body)
        .multilineTextAlignment(.center)

      Spacer()

      PrimaryButton("Försök igen") {
        onRetry()
      }

      if let onAbort {
        Button("Avbryt", action: onAbort)
      }
    }
  }
}

#Preview("Without abort") {
  WalletErrorView(
    title: "Något gick fel!",
    message: "Försök igen senare.",
    onRetry: {},
  )
  .themed
}

#Preview("With abort") {
  WalletErrorView(
    title: "Något gick fel!",
    message: "Försök igen eller avbryt.",
    onRetry: {},
    onAbort: {},
  )
  .themed
}
