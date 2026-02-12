// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct IssuanceView: View {
  private let onSave: (Credential) async -> Void
  @State private var viewModel: IssuanceViewModel
  @Environment(\.theme) private var theme
  @Environment(\.authPresentationAnchor) private var anchor
  @Environment(ToastViewModel.self) private var toastViewModel

  init(
    credentialOfferUri: String,
    gatewayAPIClient: GatewayAPI,
    onSave: @escaping (Credential) async -> Void
  ) {
    self.onSave = onSave
    _viewModel = State(
      wrappedValue: .init(
        credentialOfferUri: credentialOfferUri,
        gatewayAPIClient: gatewayAPIClient
      )
    )
  }

  var body: some View {
    VStack(spacing: 30) {
      if let display = viewModel.issuerDisplayData {
        IssuerDisplayView(issuerDisplayData: display)
      }

      if case let .credentialFetched(credential) = viewModel.state {
        CredentialView(disclosures: Array(credential.disclosures.values))
      }

      Spacer()

      button
    }
    .task {
      await viewModel.fetchIssuer()
    }
    .onChange(of: viewModel.error) { _, error in
      guard let error else {
        return
      }
      toastViewModel.showError(error.message)
    }
  }

  private var button: some View {
    switch viewModel.state {
      case .initial:
        PrimaryButton("Hämta metadata") {
          Task {
            await viewModel.fetchIssuer()
          }
        }

      case .issuerFetched(let offer):
        PrimaryButton("Logga in", icon: "arrow.right.circle.fill") {
          Task {
            guard let anchor else {
              return
            }
            await viewModel.authorize(
              credentialOffer: offer,
              authPresentationAnchor: anchor
            )
          }
        }

      case .authorized(let request):
        PrimaryButton("Hämta ID-handling") {
          Task {
            await viewModel.fetchCredential(request)
          }
        }

      case .credentialFetched(let credential):
        PrimaryButton("Godkänn", icon: "checkmark.circle") {
          Task {
            await onSave(credential)
          }
        }
    }
  }
}
