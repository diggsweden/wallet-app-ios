import SwiftUI
import WalletMacrosClient

struct WelcomeScreen: View {
  let onComplete: () -> Void
  @Environment(\.theme) private var theme

  var body: some View {
    VStack(alignment: .center) {
      Image(.welcome)
        .resizable()
        .scaledToFit()
        .frame(height: 350)

      Text("Din data, ditt val")
        .textStyle(.h1)
        .padding(.top, 20)

      Spacer()

      PrimaryButton("onboardingNext") {
        onComplete()
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .toolbar {
      ToolbarItem(placement: .principal) {
        Color.clear
      }
    }
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  WelcomeScreen {}
    .padding()
    .themed
}
