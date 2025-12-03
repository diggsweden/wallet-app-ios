import SwiftUI

struct PrimaryButton: View {
  let text: String
  let icon: String?
  let maxWidth: CGFloat
  let onClick: () -> Void
  @Environment(\.theme) private var theme
  @Environment(\.isEnabled) private var isEnabled
  @Environment(\.orientation) private var orientation

  init(
    _ text: String,
    icon: String? = nil,
    maxWidth: CGFloat = 360,
    onClick: @escaping () -> Void
  ) {
    self.text = text
    self.icon = icon
    self.maxWidth = maxWidth
    self.onClick = onClick
  }

  var body: some View {
    Button {
      onClick()
    } label: {
      HStack(alignment: .firstTextBaseline, spacing: 4) {
        Text(LocalizedStringKey(text))
          .lineHeightIfAvailable(multiple: nil)
        if let icon {
          Image(systemName: icon)
        }
      }
      .padding(.vertical, 12)
      .padding(.horizontal, 20)
      .frame(maxWidth: maxWidth)
      .background(
        theme.colors.button.opacity(isEnabled ? 1 : 0.5),
        in: RoundedRectangle(cornerRadius: theme.cornerRadius)
      )
      .foregroundStyle(theme.colors.onPrimary)
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  VStack {
    PrimaryButton("WIDTH", maxWidth: 60) {}
    PrimaryButton("TEST", icon: "heart") {}
  }
  .themed
}
