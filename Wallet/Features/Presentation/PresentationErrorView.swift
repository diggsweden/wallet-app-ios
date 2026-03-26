// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct PresentationErrorView: View {
  let onRetry: () -> Void
  let onDismiss: () -> Void
  @Environment(\.theme) private var theme

  var body: some View {
    VStack(spacing: 50) {
      Text("Något gick fel!")
        .textStyle(.h1)
        .padding(.top, 50)

      Image(systemName: "exclamationmark.triangle.fill")
        .font(.system(size: 64))
        .foregroundStyle(theme.colors.errorInverse)

      Spacer()

      PrimaryButton("Försök igen") {
        onRetry()
      }
    }
  }
}
