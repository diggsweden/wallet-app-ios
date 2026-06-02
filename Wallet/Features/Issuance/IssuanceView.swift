// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftAccessMechanism
import SwiftUI
import WalletGatewayInterface

struct IssuanceView: View {
  private let onSave: (SavedCredential) async -> Void
  @State private var viewModel: IssuanceViewModel
  @Environment(\.theme) private var theme
  @Environment(\.authPresentationAnchor) private var anchor
  @Environment(ToastViewModel.self) private var toastViewModel

  init(
    credentialOfferUri: String,
    gatewayApiClient: any GatewayApi & BFFTransport,
    onSave: @escaping (SavedCredential) async -> Void,
  ) {
    self.onSave = onSave
    _viewModel = State(
      wrappedValue: .init(
        credentialOfferUri: credentialOfferUri,
        gatewayApiClient: gatewayApiClient,
      )
    )
  }

  var body: some View {
    Group {
      if case .readyToSign = viewModel.phase {
        ConfirmPinView { pin in
          Task { await viewModel.createProof(with: pin) }
        }
      } else {
        VStack(spacing: 30) {
          if let display = viewModel.issuerDisplayData {
            IssuerDisplayView(issuerDisplayData: display)
          }

          if case let .done(_, displayClaims) = viewModel.phase {
            CredentialView(claims: displayClaims)
          }

          Spacer()

          button
        }
      }
    }
    .task {
      await viewModel.start()
    }
    .onChange(of: viewModel.error) { _, error in
      guard let error else {
        return
      }

      toastViewModel.showError(error.message)
    }
  }

  @ViewBuilder
  private var button: some View {
    switch viewModel.phase {
      case .fetchingIssuer, .authorizing, .fetchingCredential:
        ProgressView()

      case .readyToAuthorize:
        PrimaryButton("Logga in", icon: "arrow.right.circle.fill") {
          Task {
            guard let anchor else {
              return
            }

            await viewModel.beginAuthorization(anchor: anchor)
          }
        }

      case .readyToFetch:
        PrimaryButton("Försök igen") {
          Task { await viewModel.fetchCredential() }
        }

      case .done(let savedCredential, _):
        PrimaryButton("Godkänn", icon: "checkmark.circle") {
          Task { await onSave(savedCredential) }
        }

      case .readyToSign:
        EmptyView()
    }
  }
}

private struct ConfirmPinView: View {
  let onComplete: (String) -> Void

  var body: some View {
    VStack(spacing: 24) {
      Text("Bekräfta pinkod")
        .textStyle(.h2)

      PinView(onComplete: onComplete)
    }
  }
}
