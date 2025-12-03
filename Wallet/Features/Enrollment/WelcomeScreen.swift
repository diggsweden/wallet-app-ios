import SwiftUI

struct WelcomeScreen: View {
  let onComplete: () -> Void

  var body: some View {
    VStack(alignment: .center) {
      Image(.diggLogo)
        .resizable()
        .scaledToFit()
        .frame(height: 200)

      Text("Välkommen!")
        .textStyle(.h1)
        .padding(.bottom, 20)

      Text(
        "Detta är en demo av den svenska identitetsplånboken. Fortsätt för att skapa ett konto och ladda ner ditt ID-bevis."
      )

      Spacer()

      PrimaryButton("enrollmentNext") {
        onComplete()
      }
      .padding(.bottom, 25)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

#Preview {
  WelcomeScreen {}
    .padding()
    .themed
}
