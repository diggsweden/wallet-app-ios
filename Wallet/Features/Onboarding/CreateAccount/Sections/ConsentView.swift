import SwiftUI
import WalletMacrosClient

struct ConsentView: View {
  let onComplete: () -> Void
  @State private var hasAccepted: Bool = false
  @State private var didAttemptSubmit: Bool = false
  @Environment(\.theme) private var theme
  @Environment(\.openURL) private var openURL

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack(alignment: .top) {
        Image(.handshake)
          .resizable()
          .foregroundStyle(theme.colors.linkPrimary)
          .frame(width: 40, height: 40)
          .alignmentGuide(.top) { d in
            d[VerticalAlignment.center] - 12
          }
        Checkbox(isOn: $hasAccepted)
          .padding(.trailing, 4)
        VStack(alignment: .leading) {
          Text("Samtycke")
            .bold()
          Text(
            "Ja, jag samtycker till att Digg får lagra mina användar-uppgifter såsom telefonnummer och e-postadress"
          )

          if !hasAccepted && didAttemptSubmit {
            HStack(alignment: .top, spacing: 6) {
              Image(systemName: "exclamationmark.circle")
                .bold()
              Text("Samtycke krävs för att du ska kunna använda plånboken")
                .textStyle(.bodySmall)
            }
            .padding(.top, 6)
            .foregroundStyle(theme.colors.errorInverse)
          }
        }
      }
      .padding(.bottom, 20)
      .onTapGesture {
        hasAccepted.toggle()
      }

      InlineLink(
        "Läs mer om användarvillkor",
        url: #URL("https://wallet.sandbox.digg.se")
      )
      .padding(.bottom, 4)

      InlineLink(
        "Så behandlar vi dina personuppgifter",
        url: #URL("https://www.digg.se/om-oss/sa-behandlar-vi-dina-personuppgifter")
      )

      Spacer()

      PrimaryButton("onboardingNext") {
        guard hasAccepted else {
          didAttemptSubmit = true
          return
        }

        onComplete()
      }
    }
  }
}

#Preview {
  ConsentView {}
    .padding()
    .themed
}
