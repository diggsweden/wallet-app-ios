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
  @Environment(\.authPresentationAnchor) private var anchor
  @Environment(Router.self) private var router
  @Environment(\.webAuthenticationSession) private var webAuthSession

  init(
    credentialOfferUri: String,
    gatewayApiClient: any GatewayApi & HSMTransport,
    hsmServerParameters: HsmServerParameters?,
    onSaveCredential: @escaping (SavedCredential) async throws -> Void,
  ) {
    _viewModel = State(
      wrappedValue: .init(
        credentialOfferUri: credentialOfferUri,
        gatewayApiClient: gatewayApiClient,
        hsmServerParameters: hsmServerParameters,
        onSaveCredential: onSaveCredential,
      )
    )
  }

  var body: some View {
    // swiftlint:disable:next closure_body_length
    VStack {
      switch viewModel.state {
        case .idle:
          EmptyView()

        case .step(let step):
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

            default:
              ProgressView()
          }

        case .failed(_, let error):
          ErrorView(
            model: .init(
              caughtError: error,
              primaryButton: .init(
                label: "HEHE",
                accessibilityHint: "XD",
                action: {
                  print("ERROR ERROR ERROR")
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
    ToolbarItem(placement: .bottomBar) {
      if case .step(let step) = viewModel.state {
        issuanceToolbarButton(for: step)
      }
    }
    .sharedBackgroundVisibilityHiddenIfPossible()
  }

  @ContentBuilder
  func issuanceToolbarButton(for step: IssuanceStep) -> some View {
    switch step {
      case .preparingToAuthorize:
        PrimaryButton("LOGIN", maxWidth: .infinity) {
          Task {
            await viewModel.login(authenticate: webAuthSession.handler())
          }
        }

      case .done(let issuedCredential):
        PrimaryButton("Done", maxWidth: .infinity) {
          print("hej")
        }

      default:
        EmptyView()
    }
  }
}

private struct ConfirmPinView: View {
  let onComplete: (String) -> Void

  var body: some View {
    VStack(spacing: 24) {
      Text("Skriv in din PIN-kod för att begära hämtning av dina personuppgifter")
        .textStyle(.bodyLarge)
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)

      PinView(onComplete: onComplete)
    }
  }
}
