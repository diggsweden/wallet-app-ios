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
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(theme.fonts.h6)

      content()
        .textFieldStyle(.primary(error: error != nil))

      if let error {
        HStack(spacing: 6) {
          Image(systemName: "exclamationmark.circle")
            .bold()
            .foregroundStyle(theme.colors.errorInverse)
          Text(error)
            .font(theme.fonts.bodySmall)
        }
      }
    }
    .animation(.easeInOut, value: error != nil)
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
