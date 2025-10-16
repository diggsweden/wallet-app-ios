import SwiftUI

struct CardView<Content: View>: View {
  let content: () -> Content
  @Environment(\.theme) private var theme

  var body: some View {
    content()
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 12, style: .continuous)
          .fill(theme.colors.primary.opacity(0.2))
      )
      .padding(.horizontal)
  }
}
