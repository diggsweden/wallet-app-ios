import SwiftUI

struct PrimaryTextFieldStyle: TextFieldStyle {
  func _body(configuration: TextField<Self._Label>) -> some View {
    configuration
      .padding(12)
      .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
  }
}

extension TextFieldStyle where Self == PrimaryTextFieldStyle {
  static var primary: PrimaryTextFieldStyle { PrimaryTextFieldStyle() }
}
