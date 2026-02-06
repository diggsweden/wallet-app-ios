import OpenID4VCI
import SwiftUI

struct IssuerDisplayView: View {
  let issuerDisplayData: IssuerDisplay

  var body: some View {
    VStack(spacing: 12) {
      AsyncImage(url: issuerDisplayData.imageUrl)
        .frame(maxWidth: .infinity, maxHeight: 200, alignment: .center)
        .padding(.bottom, 10)

      VStack(spacing: 5) {
        Text("Utfärdare:").textStyle(.h3)
        Text(issuerDisplayData.name)
      }
    }
    .frame(maxWidth: .infinity)
  }
}
