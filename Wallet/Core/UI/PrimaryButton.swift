import SwiftUI

struct PrimaryButton: View {
  let label: String
  let onClick: () -> Void
  let enabled: Bool = true

  var body: some View {
    Button {
      onClick()
    } label: {
      Text(label)
        .padding(.vertical, 6)
        .padding(.horizontal, 24)
    }
    .buttonStyle(.borderedProminent)
    .tint(Theme.primaryColor)
  }
}
