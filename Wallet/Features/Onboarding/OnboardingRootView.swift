import SwiftData
import SwiftUI
import WalletMacrosClient

struct OnboardingRootView: View {
  let userSnapshot: UserSnapshot

  @Environment(\.gatewayAPIClient) private var gatewayAPIClient
  @Environment(\.theme) private var theme
  @Environment(\.orientation) private var orientation
  @Environment(\.openURL) private var openURL
  @State private var viewModel: OnboardingViewModel

  init(
    userSnapshot: UserSnapshot,
    setKeyAttestation: @escaping (String) async -> Void,
    signIn: @escaping (String) async -> Void,
    onReset: @escaping () async -> Void
  ) {
    self.userSnapshot = userSnapshot
    _viewModel = State(
      wrappedValue: .init(
        setKeyAttestation: setKeyAttestation,
        signIn: signIn,
        onReset: onReset
      )
    )
  }

  var body: some View {
    GeometryReader { proxy in
      ScrollView(showsIndicators: false) {
        adaptiveStack {
          if viewModel.step != .intro {
            header
          }

          currentStepView
            .transition(
              stepTransition.combined(with: .opacity)
            )
        }
        .frame(
          maxWidth: .infinity,
          minHeight: proxy.size.height,
          alignment: .top
        )
        .animation(.easeInOut, value: viewModel.step)
        .padding(.horizontal, 25)
      }
    }
    .toolbar {
      toolbarContent
    }
  }

  private var stepTransition: AnyTransition {
    if viewModel.step == .intro {
      return .opacity
    }

    return orientation.isLandscape ? .move(edge: .bottom) : .slide
  }

  private var header: some View {
    VStack(spacing: 40) {
      stepCountView

      title
        .fixedSize(horizontal: false, vertical: true)
        .id(viewModel.step)
        .transition(.blurReplace)
    }
  }

  @ViewBuilder
  private func adaptiveStack<Content: View>(
    @ViewBuilder content: () -> Content
  ) -> some View {
    if (viewModel.step == .pin || viewModel.step == .verifyPin) && orientation.isLandscape {
      HStack(spacing: 24) {
        content()
      }
    } else {
      VStack(spacing: 50) {
        content()
      }
    }
  }

  @ViewBuilder
  private var stepCountView: some View {
    if let currentStepNumber = viewModel.currentStepNumber {
      VStack(alignment: .leading, spacing: 20) {
        Text("Steg \(currentStepNumber) av \(viewModel.totalSteps)")
        PrimaryProgressView(
          value: CGFloat(currentStepNumber),
          total: CGFloat(viewModel.totalSteps)
        )
      }
    }
  }

  private var title: some View {
    let stepCount = viewModel.currentStepNumber.map { "\($0). " }
    let titleText =
      switch viewModel.step {
        case .intro: ""
        case .terms: "Tillåt behörigheter"
        case .phoneNumber: "Ditt telefonnummer"
        case .verifyPhone: "Kod för bekräftelse"
        case .email: "Din e-postadress"
        case .verifyEmail: "Bekräfta e-post"
        case .pin: "Ange ny PIN-kod för identifiering"
        case .verifyPin: "Bekräfta PIN-kod för identifiering"
        case .wua: "Sätter upp plånbok"
        case .pid: "Hämta uppgifter"
      }

    return Text("\(stepCount, default: "")\(titleText)")
      .textStyle(.h1)
  }

  @ViewBuilder
  private var currentStepView: some View {
    switch viewModel.step {
      case .intro:
        WelcomeScreen {
          viewModel.next()
        }

      case .terms:
        TermsAndConditionsView {
          viewModel.next()
        }

      case .phoneNumber:
        AddPhoneNumberForm { phoneNumber in
          viewModel.setPhoneNumber(phoneNumber)
        } onSkip: {
          viewModel.skipPhoneNumber()
        }

      case .verifyPhone:
        ContactInfoOneTimeCode(contactInfoData: viewModel.phoneNumber ?? "", type: .phone) {
          viewModel.next()
        }

      case .email:
        AddEmailForm(
          gatewayAPIClient: gatewayAPIClient,
          phoneNumber: viewModel.phoneNumber
        ) { accountId, email in
          await viewModel.signIn(accountId: accountId, email: email)
        }

      case .verifyEmail:
        ContactInfoOneTimeCode(contactInfoData: viewModel.email, type: .email) {
          viewModel.next()
        }

      case .pin:
        VStack(spacing: 20) {
          Text("Pinkod används när du ska identifiera dig")
            .textStyle(.bodyLarge)
          PinView(buttonText: "onboardingNext") { pin in
            try viewModel.setPin(pin)
          }
          .frame(maxWidth: .infinity, alignment: .center)
        }

      case .verifyPin:
        VStack(spacing: 20) {
          Text("Pinkod används när du ska identifiera dig")
            .textStyle(.bodyLarge)
          PinView(buttonText: "Bekräfta") { pin in
            try viewModel.confirmPin(pin)
          }
          .frame(maxWidth: .infinity, alignment: .center)
        }

      case .wua:
        WuaView(
          walletId: userSnapshot.deviceId,
          gatewayAPIClient: gatewayAPIClient
        ) { jwt in
          Task {
            await viewModel.addKeyAttestation(jwt)
          }
        }

      case .pid:
        OnboardingInfoView(bodyText: "För att använda appen behöver du lägga till en ID-handling") {
          let url = #URL("https://wallet.sandbox.digg.se/prepare-credential-offer")
          openURL(url)
        }
        .onChange(of: userSnapshot.credential) {
          viewModel.next()
        }
    }
  }

  @ToolbarContentBuilder
  private var toolbarContent: some ToolbarContent {
    if viewModel.canGoBack() {
      ToolbarItem(placement: .navigation) {
        Button {
          viewModel.back()
        } label: {
          Image(systemName: "chevron.left")
        }
      }
    }

    if viewModel.step != .intro {
      ToolbarItem(placement: .destructiveAction) {
        Button {
          Task {
            await viewModel.reset()
          }
        } label: {
          Image(systemName: "xmark")
        }
      }
    }
  }
}

#Preview {
  OnboardingRootView(
    userSnapshot: UserSnapshot(
      deviceId: "",
      accountId: nil,
      walletUnitAttestation: nil,
      credential: nil
    ),
    setKeyAttestation: { _ in },
    signIn: { _ in },
    onReset: {}
  )
  .themed
}
