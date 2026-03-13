// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct IssuanceView: View {
  private let onSave: (SavedCredential) async -> Void
  @State private var viewModel: IssuanceViewModel
  @Environment(\.theme) private var theme
  @Environment(\.authPresentationAnchor) private var anchor
  @Environment(ToastViewModel.self) private var toastViewModel

  init(
    credentialOfferUri: String,
    gatewayApiClient: GatewayApi,
    onSave: @escaping (SavedCredential) async -> Void
  ) {
    self.onSave = onSave
    _viewModel = State(
      wrappedValue: .init(
        credentialOfferUri: credentialOfferUri,
        gatewayApiClient: gatewayApiClient
      )
    )
  }

  var body: some View {
    VStack(spacing: 30) {
      if let display = viewModel.issuerDisplayData {
        IssuerDisplayView(issuerDisplayData: display)
      }

      if case let .credentialFetched(credential: (_, displayClaims)) = viewModel.state {
        CredentialView(claims: displayClaims)
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

      case .credentialFetched(credential: (let savedCredential, _)):
        PrimaryButton("Godkänn", icon: "checkmark.circle") {
          Task {
            await onSave(savedCredential)
          }
        }
    }
  }
}
