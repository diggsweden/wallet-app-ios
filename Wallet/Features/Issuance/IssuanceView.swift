// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import DesignSystem
import OpenId4VCInterface
import SwiftAccessMechanism
import SwiftUI
import User
import WalletGatewayInterface
import AuthenticationServices

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
    ZStack {
      switch viewModel.state {
        case .idle:
          EmptyView()

        case .step(let step):
          switch step {
            case .readyToAuthorize:
              PrimaryButton("LOGIN") {
                Task {
                  await viewModel.login(anchor: anchor)
                }
              }

            case .awaitingPin:
              PinView { pin in
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
                  print("HEJ JOHNNY")
                },
              ),
            )
          )

        case .complete:
          EmptyView()
      }
    }
    .task { await viewModel.start() }
  }
}

// MARK: - Child Views
private extension IssuanceView {
  //  @ViewBuilder
  //  private var button: some View {
  //    switch viewModel.phase {
  //      case .fetchingIssuer, .authorizing, .fetchingCredential:
  //        ProgressView()
  //
  //      case .readyToAuthorize:
  //        PrimaryButton("Logga in", icon: "arrow.right.circle.fill") {
  //          Task {
  //            guard let anchor else { return }
  //            await viewModel.beginAuthorization(anchor: anchor)
  //          }
  //        }
  //
  //      case .readyToFetoch:
  //        PrimaryButton("Försök igen") {
  //          Task { await viewModel.fetchCredential() }
  //        }
  //
  //      case .done(let savedCredential, _):
  //        PrimaryButton("Godkänn", icon: "checkmark.circle") {
  //          Task { await viewModel.saveCredential(savedCredential) }
  //        }
  //
  //      case .readyToSign:
  //        EmptyView()
  //    }
  //  }
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
