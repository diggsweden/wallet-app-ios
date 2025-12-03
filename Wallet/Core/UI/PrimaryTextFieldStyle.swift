import SwiftUI

struct PrimaryTextFieldStyle: TextFieldStyle {
  var error: Bool
  @Environment(\.theme) private var theme
  @FocusState private var isFocused: Bool

  func _body(configuration: TextField<Self._Label>) -> some View {
    let shape = RoundedRectangle(cornerRadius: 4)
    let strokeColor =
      if error {
        theme.colors.errorInverse
      } else if isFocused {
        theme.colors.borderInteractive
      } else {
        Color.clear
      }

    configuration
      .focused($isFocused)
      .padding(10)
      .background(error ? theme.colors.secondary : theme.colors.backgroundPage, in: shape)
      .overlay(shape.stroke(strokeColor, lineWidth: 2))
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
  VStack(spacing: 20) {
    TextField("Test", text: $text)
      .textFieldStyle(.primary(error: true))
    TextField("Test", text: $text)
      .textFieldStyle(.primary)
  }
  .padding(12)
  .themed
}
