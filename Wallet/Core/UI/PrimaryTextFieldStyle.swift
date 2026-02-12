// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct PrimaryTextFieldStyle: TextFieldStyle {
  var error: Bool
  @Environment(\.theme) private var theme
  @FocusState private var isFocused: Bool

  func _body(configuration: TextField<Self._Label>) -> some View {
    let shape = RoundedRectangle(cornerRadius: theme.cornerRadius)
    let strokeColor = error ? theme.colors.errorInverse : theme.colors.borderInteractive
    let lineWidth: CGFloat = isFocused ? 2 : 1

    configuration
      .focused($isFocused)
      .padding(10)
      .background(error ? theme.colors.secondaryAccent : .clear, in: shape)
      .tint(theme.colors.borderInteractive)
      .overlay(shape.strokeBorder(strokeColor, lineWidth: lineWidth))
      .clipShape(shape)
      .animation(.snappy, value: isFocused)
  }
}

extension TextFieldStyle where Self == PrimaryTextFieldStyle {
  static func primary(error: Bool) -> PrimaryTextFieldStyle {
    PrimaryTextFieldStyle(error: error)
  }
  static var primary: PrimaryTextFieldStyle { PrimaryTextFieldStyle(error: false) }
}

#Preview {
  @Previewable
  @State
  var text: String = ""

  @Previewable
  @FocusState
  var focused: Bool

  VStack(spacing: 20) {
    TextField("Error", text: $text)
      .textFieldStyle(.primary(error: true))
    TextField("Test", text: $text)
      .textFieldStyle(.primary)
    TextField("Focused", text: $text)
      .textFieldStyle(.primary)
      .focused($focused)
  }
  .padding(12)
  .themed
}
