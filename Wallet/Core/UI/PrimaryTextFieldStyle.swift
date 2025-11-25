import SwiftUI

struct PrimaryTextFieldStyle: TextFieldStyle {
  var error: Bool
  @Environment(\.theme) var theme

  func _body(configuration: TextField<Self._Label>) -> some View {
    let shape = RoundedRectangle(cornerRadius: 4)
    configuration
      .padding(10)
      .background(error ? theme.colors.secondary : theme.colors.background, in: shape)
      .overlay(
        shape.stroke(error ? theme.colors.errorInverse : theme.colors.stroke, lineWidth: 2)
      )
  }
}

extension TextFieldStyle where Self == PrimaryTextFieldStyle {
  static func primary(error: Bool) -> PrimaryTextFieldStyle {
    PrimaryTextFieldStyle(error: error)
  }
  static var primary: PrimaryTextFieldStyle { PrimaryTextFieldStyle(error: false)}
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
