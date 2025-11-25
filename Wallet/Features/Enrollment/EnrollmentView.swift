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

    ScrollView {
      adaptiveStack {
        Image(.diggLogo)
          .resizable()
          .scaledToFit()
          .frame(height: 16)

        Text("Kom igång med plånboken")
          .font(theme.fonts.h4)
          .padding(.horizontal, 20)
          .padding(.vertical, 12)
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(theme.colors.primaryVariant)
          .padding(.horizontal, -30)
          .padding(.vertical, -5)

        stepCountView

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
      .padding(.top, 10)
      .padding(.horizontal, 25)
    }
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
        VStack(alignment: .leading, spacing: 20) { content() }
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
      Text("Steg \(currentStepNumber) av \(flow.totalSteps)").font(theme.fonts.bodyLarge)
    }
  }

  private var headerView: some View {
    VStack(alignment: .leading, spacing: 28) {
      switch flow.step {
        case .intro:
          titleWithCount("Välkommen!")

        case .contactInfo:
          titleWithCount("Användaruppgifter")

        case .pin:
          Image(systemName: "lock.open.fill")
          titleWithCount("Ange ny PIN-kod")
          Text("6 siffror")
            .font(theme.fonts.body)

        case .verifyPin:
          Image(systemName: "lock.fill")
          titleWithCount("Bekräfta PIN-kod")
          Text("6 siffror")
            .font(theme.fonts.body)

        case .wua:
          Image(systemName: "gearshape.arrow.trianglehead.2.clockwise.rotate.90")
          titleWithCount("Sätter upp plånbok")

        case .pid:
          Image(systemName: "person.text.rectangle")
          titleWithCount("Lägg till ID-handling")

        case .done:
          Image(systemName: "checkmark.circle.fill")
            .foregroundStyle(Color.green)
          Text("Klart!")
      }
    }
  }

  private func titleWithCount(_ text: String) -> some View {
    if let currentStepNumber = flow.currentStepNumber {
      Text("\(currentStepNumber). \(text)")
        .font(theme.fonts.h3)
    } else {
      Text(text)
        .font(theme.fonts.h3)
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

      case .verifyPin:
        PinView(buttonText: "Bekräfta") { pin in
          context.verifyPin = pin
          try advanceIfValid()
        }

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
}
