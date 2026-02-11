// SPDX-FileCopyrightText: 2026 diggsweden/wallet-app-ios
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct PrimaryTextFieldWrapper<Content: View>: View {
  let title: String
  let error: String?
  let infoCaption: String?
  @ViewBuilder var content: () -> Content
  @Environment(\.theme) private var theme

  init(
    title: String,
    error: String? = nil,
    infoCaption: String? = nil,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.title = title
    self.error = error
    self.infoCaption = infoCaption
    self.content = content
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .textStyle(.h6)

      content()
        .textFieldStyle(.primary(error: error != nil))
        .lineHeightIfAvailable(multiple: nil)

      if let infoCaption {
        Text(infoCaption)
          .textStyle(.bodySmall)
          .foregroundStyle(theme.colors.textInformation)
      }

      if let error {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
          Image(systemName: "exclamationmark.circle")
            .font(.system(size: 18))
            .bold()
            .foregroundStyle(theme.colors.errorInverse)
          Text(error)
            .textStyle(.bodySmall)
            .foregroundStyle(theme.colors.textError)
        }
        .transition(.scale.combined(with: .opacity))
      }
    }
    .animation(.snappy, value: error != nil)
  }
}

#Preview {
  @Previewable
  @State
  var text: String = ""
  VStack(spacing: 20) {
    PrimaryTextFieldWrapper(title: "Test", error: "Något gick fel") {
      TextField("Test", text: $text)
    }

    PrimaryTextFieldWrapper(title: "Test 2") {
      TextField("Test", text: $text)
    }

    Divider()

    PrimaryTextFieldWrapper(
      title: "Test med info och fel",
      error: "Något gick fel",
      infoCaption: "Info"
    ) {
      TextField("Test", text: $text)
    }

    PrimaryTextFieldWrapper(title: "Test med info", infoCaption: "Information") {
      TextField("Test", text: $text)
    }
  }
  .padding(12)
  .themed
}
