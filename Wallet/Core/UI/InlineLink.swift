import SwiftUI

struct InlineLink: View {
  let text: String
  let url: URL
  @Environment(\.theme) private var theme
  @Environment(\.openURL) private var openURL

  init(_ text: String, url: URL) {
    self.text = text
    self.url = url
  }

  var body: some View {
    Button {
      openURL(url)
    } label: {
      HStack(alignment: .center) {
        Text(text)
          .underline()
        Image(systemName: "arrow.up.forward.app")
      }
      .foregroundStyle(theme.colors.linkPrimary)
    }
  }
}
