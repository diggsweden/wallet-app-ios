import OpenID4VCI
import SwiftUI

struct IssuerDisplayView: View {
  let issuerDisplayData: Display

  var body: some View {
    VStack(spacing: 12) {
      AsyncImage(url: issuerDisplayData.logo?.uri)
        .frame(maxWidth: .infinity, maxHeight: 200, alignment: .center)
        .padding(.bottom, 10)

      VStack(spacing: 5) {
        Text("Utfärdare:").textStyle(.h3)
        Text(issuerDisplayData.name ?? "Inget namn")
      }
    }
    .frame(maxWidth: .infinity)
  }
}
