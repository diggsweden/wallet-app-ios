import SwiftUI

struct CardView<Content: View>: View {
  let content: () -> Content

  var body: some View {
    content()
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 12, style: .continuous)
          .fill(Theme.primaryColor.opacity(0.2))
      )
      .padding(.horizontal)
  }
}
