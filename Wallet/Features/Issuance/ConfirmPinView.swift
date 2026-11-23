// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI
import UIComponents

struct ConfirmPinView: View {
  let isLoading: Bool
  let onComplete: (String) -> Void

  var body: some View {
    VStack(spacing: 24) {
      Text("Skriv in din PIN-kod för att begära hämtning av dina personuppgifter")
        .textStyle(.bodyLarge)
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)

      PinView(
        submitLabel: "Begär personuppgifter",
        isLoading: isLoading,
        onSubmit: onComplete,
      )
    }
  }
}
