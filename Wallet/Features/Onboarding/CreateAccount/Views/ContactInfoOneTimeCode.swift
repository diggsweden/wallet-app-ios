// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct ContactInfoOneTimeCode: View {
  enum ContactInfoType {
    case phone
    case email

    var description: String {
      return switch self {
        case .phone: "ditt telefonnummer"
        case .email: "din e-postadress"
      }
    }
  }

  let contactInfoData: String
  let type: ContactInfoType
  let onComplete: () -> Void
  let length: Int = 6

  @State private var code = ""
  @FocusState private var isFocused: Bool

  var body: some View {
    VStack(spacing: 30) {
      HStack(alignment: .top) {
        Text(
          "En kod för att bekräfta \(type.description) har skickats till\n**\(contactInfoData).**"
        )
        .fixedSize(horizontal: false, vertical: true)
        Image(.verifyCode)
          .resizable()
          .scaledToFit()
          .frame(width: 134)
      }

      Text(
        "Det kan ta några minuter innan du får din kod, den är aktiv i en timme."
      )
      .textStyle(.bodySmall)

      codeInput

      Spacer()

      PrimaryButton("onboardingNext") {
        guard code.count == length else {
          return
        }

        onComplete()
      }
    }
    .contentShape(Rectangle())
    .onTapGesture {
      isFocused = false
    }
  }

  private var codeInput: some View {
    ZStack {
      HStack(spacing: 15) {
        ForEach(0 ..< length, id: \.self) { i in
          Text(char(at: i))
            .textStyle(.h2)
            .frame(width: 30, height: 50)
            .overlay(
              Rectangle().frame(height: 2),
              alignment: .bottom
            )
            .padding(.trailing, ((i + 1) == length / 2 ? 15 : 0))
            .accessibilityHidden(true)
        }
      }

      TextField("", text: $code)
        .focused($isFocused)
        .textContentType(.oneTimeCode)
        .keyboardType(.numberPad)
        .textInputAutocapitalization(.never)
        .disableAutocorrection(true)
        .onChange(of: code) {
          if code.count == length {
            isFocused = false
          }
        }
        .opacity(0)
        .accessibilityLabel("Verifieringskod")
        .accessibilityValue("\(code.count) av \(length) siffror")
    }
    .accessibilityElement(children: .combine)
    .contentShape(Rectangle())
    .onTapGesture {
      isFocused = true
    }
  }

  private func char(at index: Int) -> String {
    guard index < code.count else {
      return " "
    }
    let i = code.index(code.startIndex, offsetBy: index)
    return String(code[i])
  }
}

#Preview {
  VStack {
    ContactInfoOneTimeCode(contactInfoData: "test", type: .email) {
    }
  }
  .themed
  .padding()
}
