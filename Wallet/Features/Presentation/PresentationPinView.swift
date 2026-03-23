// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct PresentationPinView: View {
  let isLoading: Bool
  let onPinEntered: (String) -> Void

  var body: some View {
    if isLoading {
      ProgressView()
    } else {
      FullHeightScrollView {
        VStack(spacing: 20) {
          Text("Godkänn och identifiera")
            .textStyle(.h1)
            .frame(maxWidth: .infinity, alignment: .leading)

          Text(
            "Genom att fylla i din pinkod och identifiera dig, godkänner du delning av dina uppgifter."
          )
          .textStyle(.bodyLarge)
          .frame(maxWidth: .infinity, alignment: .leading)

          PinView(buttonText: "Dela") { pin in
            onPinEntered(pin)
          }
        }
      }
    }
  }
}
