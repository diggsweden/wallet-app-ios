import SwiftUI
import WalletMacrosClient

struct WelcomeScreen: View {
  let onComplete: () -> Void
  @Environment(\.theme) private var theme
  @Environment(\.openURL) private var openURL

  var body: some View {
    VStack(alignment: .center) {
      HStack {
        Image(.diggLogo)
          .resizable()
          .scaledToFit()
          .frame(height: 30)
        Spacer()
      }

      Image(.welcome)
        .resizable()
        .scaledToFit()
        .frame(height: 350)

      Text("Din data, ditt val")
        .textStyle(.h1)
        .padding(.top, 20)

      Spacer()

      Button {
        openURL(#URL("https://wallet.sandbox.digg.se"))
      } label: {
        HStack(alignment: .center) {
          Text("Läs mer om plånboken på wallet.se")
            .underline()
          Image(systemName: "arrow.up.forward.app")
        }
      }
      
      Spacer()

      PrimaryButton("enrollmentNext") {
        onComplete()
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

#Preview {
  WelcomeScreen {}
    .padding()
    .themed
}
