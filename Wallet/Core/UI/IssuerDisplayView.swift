import OpenID4VCI
import SwiftUI
import WalletMacrosClient

struct IssuerDisplayView: View {
  let issuerDisplayData: IssuerDisplay

  var body: some View {
    VStack(spacing: 12) {
      AsyncImage(url: issuerDisplayData.imageUrl) { image in
        image
          .resizable()
          .scaledToFit()
          .frame(maxHeight: 200)
      } placeholder: {
        ProgressView()
      }
      .fixedSize(horizontal: false, vertical: true)
      .padding(.bottom, 10)

      VStack(spacing: 5) {
        Text("Utfärdare:").textStyle(.h3)
        Text(issuerDisplayData.name)
      }
    }
    .frame(maxWidth: .infinity)
  }
}

#Preview {
  IssuerDisplayView(
    issuerDisplayData: IssuerDisplay(
      name: "Test",
      info: nil,
      imageUrl: #URL("https://dela.digg.se/img/sr-logo-color.png")
    )
  )
}
