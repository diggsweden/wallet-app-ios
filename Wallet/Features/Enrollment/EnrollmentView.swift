import SwiftData
import SwiftUI
import WalletMacrosClient

struct EnrollmentView: View {
  let userSnapshot: UserSnapshot
  let setKeyAttestation: (String) async -> Void
  let signIn: (String) async -> Void

  @Environment(\.gatewayClient) private var gatewayClient
  @Environment(\.theme) private var theme
  @Environment(\.orientation) private var orientation
  @Environment(\.openURL) private var openURL
  @State private var flow = EnrollmentFlow()
  @State private var context = EnrollmentContext()

  var body: some View {
    let slideTransition: AnyTransition = orientation.isLandscape ? .move(edge: .bottom) : .slide

    adaptiveStack {
      landscapeSpacer

      headerView
        .id(flow.step)
        .transition(.blurReplace)

      landscapeSpacer

      currentStepView
        .transition(
          slideTransition.combined(with: .opacity)
        )
    }
    .animation(.easeInOut, value: flow.step)
    .padding()
  }

  private func advanceIfValid() throws {
    try flow.advance(with: context)
  }

  @ViewBuilder
  private func adaptiveStack<Content: View>(
    @ViewBuilder content: () -> Content
  ) -> some View {
    switch orientation {
      case .landscape:
        HStack(spacing: 24) { content() }
      case .portrait:
        VStack(spacing: 24) { content() }
    }
  }

  @ViewBuilder
  private var landscapeSpacer: some View {
    if orientation.isLandscape {
      Spacer()
    }
  }

  private var headerView: some View {
    VStack(spacing: 12) {
      switch flow.step {
        case .intro:
          Image(.diggLogo)
          Text("Välkommen!")

        case .contactInfo:
          Image(systemName: "person.badge.plus")
          Text("Kontaktuppgifter")

        case .pin:
          Image(systemName: "lock.open.fill")
          Text("Ange ny PIN-kod")
          Text("6 siffror")
            .font(theme.fonts.body)

        case .verifyPin:
          Image(systemName: "lock.fill")
          Text("Bekräfta PIN-kod")
          Text("6 siffror")
            .font(theme.fonts.body)

        case .wua:
          Image(systemName: "gearshape.arrow.trianglehead.2.clockwise.rotate.90")
          Text("Sätter upp plånbok")

        case .pid:
          Image(systemName: "person.text.rectangle")
          Text("Lägg till ID-handling")

        case .done:
          Image(systemName: "checkmark.circle.fill")
            .foregroundStyle(Color.green)
          Text("Klart!")
      }
    }
    .font(theme.fonts.titleLarge)
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
        ContactInfoForm(
          gatewayClient: gatewayClient,
          keyTag: userSnapshot.deviceKeyTag,
        ) { accountId in
          await signIn(accountId)
          try advanceIfValid()
        }

      case .pin:
        PinView(buttonText: "enrollmentNext") { pin in
          context.pin = pin
          try advanceIfValid()
        }

      case .verifyPin:
        PinView(buttonText: "Bekräfta") { pin in
          context.verifyPin = pin
          try advanceIfValid()
        }

      case .wua:
        WuaView(
          walletId: userSnapshot.deviceId,
          keyTag: userSnapshot.walletKeyTag,
          gatewayClient: gatewayClient
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
      walletKeyTag: "",
      deviceKeyTag: "",
      deviceId: "",
      accountId: nil,
      walletUnitAttestation: nil,
      credential: nil
    ),
    setKeyAttestation: { _ in },
    signIn: { _ in }
  )
}
