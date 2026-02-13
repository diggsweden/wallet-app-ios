// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct OnboardingPinViewWrapper: View {
  let bodyText: String
  let onSubmit: (String) throws -> Void

  init(_ bodyText: String, onSubmit: @escaping (String) throws -> Void) {
    self.bodyText = bodyText
    self.onSubmit = onSubmit
  }

  var body: some View {
    VStack(spacing: 20) {
      Text(bodyText)
        .textStyle(.bodyLarge)
        .multilineTextAlignment(.center)

      PinView(buttonText: "onboardingNext") { pin in
        try onSubmit(pin)
      }
      .frame(maxWidth: .infinity, alignment: .center)
    }
    .padding(.top, -30)
  }
}
