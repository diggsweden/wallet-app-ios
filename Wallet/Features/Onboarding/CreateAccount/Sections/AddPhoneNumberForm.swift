// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct AddPhoneNumberForm: View {
  let onSubmit: (String) -> Void
  let onSkip: () -> Void

  @Environment(\.theme) private var theme
  @State private var phoneNumber: String = ""
  @State private var didAttemptSubmit: Bool = false
  @FocusState private var isFocused: Bool

  private var error: String? {
    guard didAttemptSubmit else {
      return nil
    }

    return isValidPhone(phoneNumber) ? nil : "Ogiltigt telefonnummer"
  }

  private func isValidPhone(_ input: String) -> Bool {
    input.wholeMatch(of: /^\d{10}$/) != nil
  }

  var body: some View {
    VStack(spacing: 8) {
      PrimaryTextFieldWrapper(
        title: "Ditt mobiltelefonnummer",
        error: error,
        infoCaption: "10 siffror, t.ex. 070 123 45 67"
      ) {
        TextField(
          "070 123 45 67",
          text: $phoneNumber
        )
        .keyboardType(.numberPad)
        .textContentType(.telephoneNumber)
        .focused($isFocused)
        .onChange(of: phoneNumber) {
          if phoneNumber.count == 10 {
            isFocused = false
          }
        }
      }

      Spacer()

      PrimaryButton("onboardingNext") {
        guard isValidPhone(phoneNumber) else {
          didAttemptSubmit = true
          return
        }

        onSubmit(phoneNumber)
      }
      .padding(.bottom, 8)

      Button {
        onSkip()
      } label: {
        Text("Hoppa över")
          .foregroundStyle(theme.colors.linkPrimary)
          .underline()
      }
    }
  }
}
