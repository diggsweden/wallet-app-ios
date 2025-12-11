import SwiftData
import SwiftUI
import WalletMacrosClient

struct EnrollmentView: View {
  let userSnapshot: UserSnapshot

  @Environment(\.gatewayAPIClient) private var gatewayAPIClient
  @Environment(\.theme) private var theme
  @Environment(\.orientation) private var orientation
  @Environment(\.openURL) private var openURL
  @State private var viewModel: EnrollmentViewModel

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
  private var landscapeSpacer: some View {
    if orientation.isLandscape {
      Spacer()
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
    VStack {
      switch viewModel.step {
        case .intro:
          EmptyView()
          
        case .terms:
          titleWithCount("Användaruppgifter")

        case .phoneNumber:
          titleWithCount("Ditt telefonnummer")

        case .verifyPhone:
          titleWithCount("Kod för bekräftelse")

        case .email:
          titleWithCount("Din e-postadress")

        case .verifyEmail:
          titleWithCount("Bekräfta e-post")

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
    if let currentStepNumber = viewModel.currentStepNumber {
      Text("\(currentStepNumber). \(text)")
        .textStyle(.h1)
    } else {
      Text(text)
        .textStyle(.h1)
    }
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
        VerifyContactInfoWithCode(contactInfoData: viewModel.phoneNumber ?? "", type: .phone) {
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
        VerifyContactInfoWithCode(contactInfoData: viewModel.email, type: .email) {
          viewModel.next()
        }

      case .pin:
        PinView(buttonText: "enrollmentNext") { pin in
          try viewModel.setPin(pin)
        }
        .frame(maxWidth: .infinity, alignment: .center)

      case .verifyPin:
        PinView(buttonText: "Bekräfta") { pin in
          try viewModel.confirmPin(pin)
        }
        .frame(maxWidth: .infinity, alignment: .center)

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
        EnrollmentInfoView(bodyText: "För att använda appen behöver du lägga till en ID-handling") {
          let url = #URL("https://wallet.sandbox.digg.se/prepare-credential-offer")
          openURL(url)
        }
        .onChange(of: userSnapshot.credential) {
          viewModel.next()
        }

      case .done:
        EnrollmentInfoView(bodyText: "Nu är din plånbok redo för att användas!") {}
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
    signIn: { _ in },
    onReset: {}
  )
  .themed
}
