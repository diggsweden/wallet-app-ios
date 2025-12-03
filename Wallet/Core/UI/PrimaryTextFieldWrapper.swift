import SwiftUI

struct PrimaryTextFieldWrapper<Content: View>: View {
  let title: String
  let error: String?
  @ViewBuilder var content: () -> Content
  @Environment(\.theme) private var theme

  init(title: String, error: String? = nil, @ViewBuilder content: @escaping () -> Content) {
    self.title = title
    self.error = error
    self.content = content
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title)
        .textStyle(.h6)

      content()
        .textFieldStyle(.primary(error: error != nil))
        .lineHeightIfAvailable(multiple: nil)

      if let error {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
          Image(systemName: "exclamationmark.circle")
            .bold()
            .foregroundStyle(theme.colors.errorInverse)
          Text(error)
            .textStyle(.bodySmall)
            .foregroundStyle(theme.colors.textError)
        }
        .transition(.scale.combined(with: .opacity))
        .padding(.top, -6)
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
  }
  .padding(12)
  .themed
}
