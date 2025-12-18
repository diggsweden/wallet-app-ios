import SwiftUI

struct PrimaryProgressView: View {
  @Environment(\.theme) private var theme
  let value: Double
  let total: Double?

  init(value: Double, total: Double? = nil) {
    self.value = value
    self.total = total
  }

  var body: some View {
    let rectangle = RoundedRectangle(cornerRadius: 8)
    rectangle
      .fill(theme.colors.backgroundPage)
      .frame(height: 11)
      .overlay(alignment: .leading) {
        GeometryReader { proxy in
          rectangle
            .stroke(theme.colors.stroke, lineWidth: 0.2)
            .fill(theme.colors.layerAccent)
            .frame(width: proxy.size.width * finalValue)
        }
      }
      .overlay {
        rectangle.stroke(theme.colors.stroke, lineWidth: 0.2)
      }
      .clipShape(rectangle)
  }

  private var finalValue: Double {
    return if let total {
      value / total
    } else {
      value
    }
  }
}

#Preview {
  VStack {
    PrimaryProgressView(value: 1, total: 3.0)
    PrimaryProgressView(value: 1, total: 2.0)
    PrimaryProgressView(value: 0.25)
    PrimaryProgressView(value: 0.50)
  }
  .themed
  .padding(20)
}
