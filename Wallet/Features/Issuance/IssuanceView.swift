// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import AuthenticationServices
import CredentialInterfaces
import DesignSystem
import OpenId4VCInterface
import SwiftAccessMechanism
import SwiftUI
import User
import WalletGatewayInterface

struct IssuanceView: View {
  @State private var viewModel: IssuanceViewModel
  @Environment(\.theme) private var theme
  @Environment(Router.self) private var router
  @Environment(\.webAuthenticationSession) private var webAuthSession

  init(
    credentialOfferUri: String,
    gatewayApiClient: any GatewayApi & HSMTransport,
    hsmServerParameters: HsmServerParameters?,
    actions: IssuanceActions,
  ) {
    _viewModel = State(
      wrappedValue: .init(
        credentialOfferUri: credentialOfferUri,
        gatewayApiClient: gatewayApiClient,
        hsmServerParameters: hsmServerParameters,
        actions: actions,
      )
    )
  }

  var body: some View {
    VStack {
      switch viewModel.state {
        case .idle:
          EmptyView()

        case .step(let step):
          issuanceStepView(step)

        case .failed(_, let error):
          ErrorView(
            model: .init(
              caughtError: error,
              primaryButton: .init(
                label: "Försök igen",
                accessibilityHint: "Välj för att försöka igen.",
                asyncAction: {
                  await viewModel.retry()
                },
              ),
            )
          )
      }
    }
    .task { await viewModel.start() }
    .toolbar { issuanceToolbar }
  }
}

private extension IssuanceView {
  @ContentBuilder
  var issuanceToolbar: some ToolbarContent {
    if case .step(let step) = viewModel.state {
      ToolbarItem(placement: .bottomBar) {
        issuanceBottomToolbarButton(for: step)
      }
      .sharedBackgroundVisibilityHiddenIfPossible()
    }

    if shouldShowDismissButton {
      ToolbarItem(placement: .destructiveAction) {
        Button {
          Task {
            await viewModel.dismiss()
          }
        } label: {
          Image(systemName: "xmark")
            .accessibilityLabel("Avbryt")
        }
      }
    }
  }

  @ContentBuilder
  func issuanceBottomToolbarButton(for step: IssuanceStep) -> some View {
    switch step {
      case .preparingToAuthorize:
        PrimaryButton("Logga in", maxWidth: .infinity) {
          Task {
            await viewModel.login(authenticate: webAuthSession.authenticator)
          }
        }

      case .awaitingCompletion, .complete:
        PrimaryButton("Fortsätt", maxWidth: .infinity) {
          Task {
            await viewModel.completeIssuance()
          }
        }

      default:
        EmptyView()
    }
  }

  var shouldShowDismissButton: Bool {
    guard case .step(let step) = viewModel.state else {
      return true
    }

    switch step {
      case .awaitingCompletion, .complete:
        return false

      default:
        return true
    }
  }

  @ContentBuilder
  func issuanceStepView(_ step: IssuanceStep) -> some View {
    VStack(spacing: 12) {
      if let issuerDisplayData = viewModel.issuerDisplayData, step != .awaitingPin {
        IssuerDisplayView(issuerDisplayData: issuerDisplayData)
      }

      switch step {
        case .preparingToAuthorize:
          EmptyView()

        case .awaitingPin:
          ConfirmPinView { pin in
            Task { await viewModel.enterPin(pin) }
          }

        case let .savingCredential(credential, _, _),
          let .awaitingCompletion(credential),
          let .complete(credential):
          CredentialView(claims: credential.claims)

        default:
          ProgressView()
      }
    }
  }
}
