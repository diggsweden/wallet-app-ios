import SwiftUI

struct WelcomeScreen: View {
  let onComplete: () -> Void
  @Environment(\.theme) private var theme

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

      Text(
        "[Så behandlar vi dina personuppgifter](https://www.digg.se/om-oss/sa-behandlar-vi-dina-personuppgifter)"
      )
      .tint(theme.colors.linkPrimary)
      .underline()

      Spacer()

      PrimaryButton("enrollmentNext") {
        onComplete()
      }
      .padding(.bottom, 25)
    }
    .toolbar {
      ToolbarItem(placement: .navigation) {
        Image(systemName: "chevron.left")
      }
      ToolbarItem(placement: .destructiveAction) {
        Image(systemName: "x.circle")
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
