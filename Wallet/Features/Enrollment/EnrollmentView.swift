import SwiftData
import SwiftUI
import WalletMacrosClient

struct EnrollmentView: View {
  let userSnapshot: UserSnapshot
  let setKeyAttestation: (String) async -> Void
  let signIn: (String) async -> Void

  @Environment(\.gatewayAPIClient) private var gatewayAPIClient
  @Environment(\.theme) private var theme
  @Environment(\.orientation) private var orientation
  @Environment(\.openURL) private var openURL
  @State private var flow = EnrollmentFlow()
  @State private var context = EnrollmentContext()

  var body: some View {
    let slideTransition: AnyTransition = orientation.isLandscape ? .move(edge: .bottom) : .slide

    ScrollView(showsIndicators: false) {
      adaptiveStack {
        header
          .padding(.bottom, 30)

        currentStepView
          .transition(
            slideTransition.combined(with: .opacity)
          )

        //        Text("Verifiera ditt konto för att fortsätta")
        //          .textStyle(.bodySmall)
        //          .padding(.top, 5)
        //          .frame(maxWidth: .infinity, alignment: .center)
      }
      .animation(.easeInOut, value: flow.step)
      .padding(.top, 10)
      .padding(.horizontal, 25)
    }
  }

  private func advanceIfValid() throws {
    try flow.advance(with: context)
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: 20) {
      Image(.diggLogo)
        .resizable()
        .scaledToFit()
        .frame(height: 16)
        .padding(.bottom, 10)

      Text("Kom igång med plånboken")
        .textStyle(.h3)

      stepCountView

      title
        .padding(.top, 10)
        .padding(.leading, 10)
        .id(flow.step)
        .transition(.blurReplace)
    }
  }

  @ViewBuilder
  private func adaptiveStack<Content: View>(
    @ViewBuilder content: () -> Content
  ) -> some View {
    if (flow.step == .pin || flow.step == .verifyPin) && orientation.isLandscape {
      HStack(spacing: 24) {
        content()
      }
    } else {
      VStack(alignment: .leading, spacing: 0) {
        content()
      }
      .frame(maxHeight: .infinity, alignment: .top)
    }
  }

  @ViewBuilder
  private var landscapeSpacer: some View {
    if orientation.isLandscape {
      Spacer()
    }
  }

  @ViewBuilder
  private var stepCountView: some View {
    if let currentStepNumber = flow.currentStepNumber {
      Text("Steg \(currentStepNumber) av \(flow.totalSteps)")
      PrimaryProgressView(
        value: CGFloat(currentStepNumber),
        total: CGFloat(flow.totalSteps)
      )
    }
  }

  private var title: some View {
    VStack(alignment: .leading) {
      switch flow.step {
        case .intro:
          titleWithCount("Välkommen!")

        case .contactInfo:
          titleWithCount("Användaruppgifter")

        case .pin:
          titleWithCount("Ange ny PIN-kod")
          Text("6 siffror")
            .textStyle(.body)

        case .verifyPin:
          titleWithCount("Bekräfta PIN-kod")
          Text("6 siffror")
            .textStyle(.body)

        case .wua:
          titleWithCount("Sätter upp plånbok")

        case .pid:
          titleWithCount("Lägg till ID-handling")

        case .done:
          Text("Klart!")
      }
    }
  }

  private func titleWithCount(_ text: String) -> some View {
    if let currentStepNumber = flow.currentStepNumber {
      Text("\(currentStepNumber). \(text)")
        .textStyle(.h2)
    } else {
      Text(text)
        .textStyle(.h2)
    }
  }

  @ViewBuilder
  private var currentStepView: some View {
    switch flow.step {
      case .intro:
        EnrollmentInfoView(
          bodyText:
            "Detta är en demo av den svenska identitetsplånboken. Fortsätt för att skapa ett konto och ladda ner ditt ID-bevis."
        ) {
          try advanceIfValid()
        }

      case .contactInfo:
        CreateAccountForm(
          gatewayAPIClient: gatewayAPIClient
        ) { accountId in
          await signIn(accountId)
          try advanceIfValid()
        }

      case .pin:
        PinView(buttonText: "enrollmentNext") { pin in
          context.pin = pin
          try advanceIfValid()
        }
        .frame(maxWidth: .infinity, alignment: .center)

      case .verifyPin:
        PinView(buttonText: "Bekräfta") { pin in
          context.verifyPin = pin
          try advanceIfValid()
        }
        .frame(maxWidth: .infinity, alignment: .center)

      case .wua:
        WuaView(
          walletId: userSnapshot.deviceId,
          gatewayAPIClient: gatewayAPIClient
        ) { jwt in
          Task {
            await setKeyAttestation(jwt)
          }
          try advanceIfValid()
        }

      case .pid:
        EnrollmentInfoView(bodyText: "För att använda appen behöver du lägga till en ID-handling") {
          let url = #URL("https://wallet.sandbox.digg.se/prepare-credential-offer")
          openURL(url)
        }
        .onChange(of: userSnapshot.credential) {
          try? advanceIfValid()
        }

      case .done:
        EnrollmentInfoView(bodyText: "Nu är din plånbok redo för att användas!") {
          let user = UserProfile(
            email: context.email,
            pin: context.pin,
            phoneNumber: context.phoneNumber
          )
        }
    }
  }
}

#Preview {
  EnrollmentView(
    userSnapshot: UserSnapshot(
      deviceId: "",
      accountId: nil,
      walletUnitAttestation: nil,
      credential: nil
    ),
    setKeyAttestation: { _ in },
    signIn: { _ in }
  )
  .themed
}
