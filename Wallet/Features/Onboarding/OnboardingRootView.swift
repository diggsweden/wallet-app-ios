// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import DesignSystem
import SwiftData
import SwiftUI
import User
import WalletGateway
import WalletMacros

struct OnboardingRootView: View {
  private let gatewayApiClient: GatewayApiClient
  private let userSnapshot: UserSnapshot

  @Environment(\.theme) private var theme
  @Environment(\.orientation) private var orientation
  @Environment(\.openURL) private var openURL
  @State private var viewModel: OnboardingViewModel
  @State private var isResetErrorAlertPresented = false

  init(
    gatewayApiClient: GatewayApiClient,
    userSnapshot: UserSnapshot,
    actions: OnboardingActions
  ) {
    self.gatewayApiClient = gatewayApiClient
    self.userSnapshot = userSnapshot
    _viewModel = State(
      wrappedValue: .init(
        savePidCredential: actions.savePidCredential,
        signIn: actions.signIn,
        onReset: actions.resetSession,
        saveHsmServerParameters: actions.saveHsmServerParameters,
      )
    )
  }

  var body: some View {
    FullHeightScrollView {
      adaptiveStack {
        if viewModel.step != .intro {
          header
        }

        currentStepView
          .id(viewModel.step)
          .transition(
            stepTransition.combined(with: .opacity)
          )
      }
      .animation(.easeInOut, value: viewModel.step)
    }
    .toolbar {
      toolbarContent
    }
    .backGesture(isEnabled: viewModel.canGoBack()) {
      viewModel.back()
    }
    .alert("Kunde inte avbryta registreringen", isPresented: $isResetErrorAlertPresented) {
      Button("Försök igen") { resetOnboarding() }
      Button("Stäng", role: .cancel) {}
    }
  }

  private var stepTransition: AnyTransition {
    switch viewModel.stepTransition {
      case .start:
        .scale

      case .forward:
        .push(from: orientation.isLandscape ? .bottom : .trailing)

      case .back:
        .push(from: orientation.isLandscape ? .top : .leading)
    }
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: 40) {
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
    if viewModel.step == .pin || viewModel.step == .verifyPin, orientation.isLandscape {
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
          total: CGFloat(viewModel.totalSteps),
        )
      }
    }
  }

  private var title: some View {
    let titleText =
      switch viewModel.step {
        case .intro: ""
        case .pin: "Ange pinkod för identifiering"
        case .verifyPin: "Bekräfta pinkod för identifiering"
        case .walletSetup: "Sätter upp plånbok"
        case .pid: "Hämta personuppgifter"
        case .issueCredential: "Hämta personuppgifter"
      }

    return Text(titleText)
      .textStyle(.h1)
  }

  @ViewBuilder
  private var currentStepView: some View {
    switch viewModel.step {
      case .intro:
        WelcomeScreen {
          viewModel.next(from: .intro)
        }

      case .pin:
        PinSetupView("Pinkod används när du ska identifiera dig") { pin in
          try viewModel.setPin(pin)
          viewModel.next(from: .pin)
        }

      case .verifyPin:
        PinSetupView("Pinkod används när du ska identifiera dig") { pin in
          try viewModel.confirmPin(pin)
          viewModel.next(from: .verifyPin)
        }

      case .walletSetup:
        WalletSetupView(
          pin: viewModel.context.pin,
          gatewayApi: gatewayApiClient,
          onAccountCreated: { accountId in
            try await viewModel.signIn(accountId: accountId)
          },
          onServerParameters: { parameters in
            try await viewModel.saveHsmServerParameters(parameters)
          },
          onComplete: {
            viewModel.next(from: .walletSetup)
          },
        )

      case .pid:
        PidSetupView { credentialOfferUri in
          viewModel.setCredentialOfferUri(credentialOfferUri)
          viewModel.next(from: .pid)
        }

      case .issueCredential:
        if let uri = viewModel.context.credentialOfferUri {
          IssuanceView(
            credentialOfferUri: uri,
            gatewayApiClient: gatewayApiClient,
            hsmServerParameters: userSnapshot.hsmServerParameters,
          ) { credential in
            try await viewModel.savePidCredential(credential)
          }
        } else {
          PidSetupView { credentialOfferUri in
            viewModel.setCredentialOfferUri(credentialOfferUri)
          }
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
            .accessibilityLabel("Tillbaka")
        }
      }
    }

    if viewModel.step != .intro {
      ToolbarItem(placement: .destructiveAction) {
        Button {
          resetOnboarding()
        } label: {
          Image(systemName: "xmark")
            .accessibilityLabel("Stäng")
        }
      }
    }
  }

  private func resetOnboarding() {
    Task { await viewModel.reset() }
  }
}

// TODO: Create mockable flow for OnboardingRootview
// #Preview {
//   OnboardingRootView(
//     gatewayApiClient: GatewayApiMock(),
//     userSnapshot: UserSnapshot(
//       accountId: nil,
//       credentials: [],
//       pid: nil
//     ),
//     savePidCredential: { _ in },
//     signIn: { _ in },
//     onReset: {}
//   )
//   .themed
// }
