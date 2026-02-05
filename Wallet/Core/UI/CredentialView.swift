import SwiftUI

struct CredentialView: View {
  let disclosures: [Disclosure]
  @Environment(\.theme) private var theme

  var body: some View {
    let shape = RoundedRectangle(cornerRadius: theme.cornerRadius)

    VStack(spacing: 26) {
      ForEach(disclosures) { disclosure in
        VStack(alignment: .leading, spacing: 5) {
          Text("\(disclosure.displayName):")
            .textStyle(.h5)
          Text(disclosure.value)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
    .padding(20)
    .background(theme.colors.backgroundPage, in: shape)
    .overlay(
      shape.stroke(theme.colors.stroke, lineWidth: 1)
    )
    .clipShape(shape)
  }
}

#Preview {
  let disclosures = (0 ..< 10)
    .map { _ in
      Disclosure(
        base64: "",
        displayName: "Test",
        value: "testar"
      )
    }

  ScrollView {
    CredentialView(disclosures: disclosures)
  }
  .padding()
  .themed
}
