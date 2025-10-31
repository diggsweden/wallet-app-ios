import SwiftUI

struct ErrorView: View {
  let text: String?
  let show: Bool
  let lines: Int = 2

  // TODO: better conversion between Font/UIFont
  private var lineHeight: CGFloat {
    UIFont.preferredFont(forTextStyle: .footnote).lineHeight
  }

  var body: some View {
    Text(text ?? "")
      .font(.footnote)
      .foregroundStyle(Color.red)
      .lineLimit(lines)
      .frame(
        maxWidth: .infinity,
        minHeight: lineHeight * CGFloat(lines),
        alignment: .leading
      )
      .opacity(show ? 1 : 0)
  }
}
