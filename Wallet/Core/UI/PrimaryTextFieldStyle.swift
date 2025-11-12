import SwiftUI

struct PrimaryTextFieldStyle: TextFieldStyle {
  var error: String?

  func _body(configuration: TextField<Self._Label>) -> some View {
    let shape = RoundedRectangle(cornerRadius: 12)
    VStack(alignment: .leading) {
      HStack {
        configuration
        if error != nil {
          Image(systemName: "exclamationmark.circle.fill")
            .foregroundStyle(Color.red)
        }
      }
      .padding(12)
      .background(.ultraThinMaterial, in: shape)
      .overlay(shape.stroke(error != nil ? Color.red : .clear))

      if let error {
        Text(error)
          .foregroundStyle(Color.red)
      }
    }
    .animation(.easeInOut, value: error != nil)
  }
}

extension TextFieldStyle where Self == PrimaryTextFieldStyle {
  static func primary(error: String?) -> PrimaryTextFieldStyle {
    PrimaryTextFieldStyle(error: error)
  }
  static var primary: PrimaryTextFieldStyle { PrimaryTextFieldStyle() }
}

#Preview {
  @Previewable
  @State
  var text: String = ""
  VStack {
    TextField("Test", text: $text)
      .textFieldStyle(PrimaryTextFieldStyle(error: "Något gick fel"))
    TextField("Test", text: $text)
      .textFieldStyle(PrimaryTextFieldStyle())
  }
  .padding(12)
  .themed
}
