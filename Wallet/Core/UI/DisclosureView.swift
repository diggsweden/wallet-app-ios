import SwiftUI

struct DisclosureView: View {
  let title: String
  let value: String
  let onToggle: ((Bool) -> Void)?
  @State var isOn: Bool = true

  init(
    title: String,
    value: String,
    onToggle: ((Bool) -> Void)? = nil
  ) {
    self.title = title
    self.value = value
    self.onToggle = onToggle
  }

  var body: some View {
    VStack(alignment: .leading) {
      Text(title).font(.caption)

      Group {
        if let onToggle {
          Toggle(value, isOn: $isOn)
            .onChange(of: isOn) { _, newValue in
              onToggle(newValue)
            }
        } else {
          Text(value).frame(maxWidth: .infinity, alignment: .leading)
        }
      }
      .toggleStyle(.switch)
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .background(
        Capsule()
          .fill(Color(.systemBackground))
          .overlay(
            Capsule()
              .stroke(Theme.primaryColor.opacity(0.4), lineWidth: 1)
          )
      )
      .containerShape(Capsule())
    }
  }
}

#if DEBUG
  #Preview {
    CardView {
      DisclosureView(
        title: "Title",
        value: "Value",
      )
    }
  }
#endif
