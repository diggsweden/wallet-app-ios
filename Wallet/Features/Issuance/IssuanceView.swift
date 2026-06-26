// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import DesignSystem
import SwiftAccessMechanism
import SwiftUI
import WalletGatewayInterface

struct IssuanceView: View {
  @State private var viewModel: IssuanceViewModel
  @Environment(\.theme) private var theme
  @Environment(\.authPresentationAnchor) private var anchor
  @Environment(ToastViewModel.self) private var toastViewModel

  init(
    credentialOfferUri: String,
    gatewayApiClient: any GatewayApi & HSMTransport,
    onSaveCredential: @escaping (SavedCredential) async throws -> Void,
  ) {
    _viewModel = State(
      wrappedValue: .init(
        credentialOfferUri: credentialOfferUri,
        gatewayApiClient: gatewayApiClient,
        onSaveCredential: onSaveCredential
      ),
    )
  }

  var body: some View {
    ZStack {
      if case .readyToSign = viewModel.phase {
        ConfirmPinView { pin in
          Task { await viewModel.createProof(with: pin) }
        }
        .transition(.opacity)
        // Remount to clear the entered digits after a failed attempt: the alert
        // keeps the PIN screen mounted, so PinView's state would otherwise persist.
        .id(viewModel.pinAttempt)
      } else {
        VStack(spacing: 30) {
          if let display = viewModel.issuerDisplayData,
            !viewModel.phase.isError
          {
            IssuerDisplayView(issuerDisplayData: display)
          }

          if case let .done(_, displayClaims) = viewModel.phase {
            CredentialView(claims: displayClaims)
          }

          if case .error = viewModel.phase {
            errorPhaseView
          }

          Spacer()

          button
        }
        .transition(.opacity)
      }
    }
    .animation(.easeInOut(duration: 0.2), value: viewModel.phase.animationKey)
    .task {
      await viewModel.start()
    }
    .alert("Kunde inte verifiera pinkoden", isPresented: $viewModel.pinError) {
      Button("Försök igen") {}
    }
    .alert("Kunde inte spara attributsintyget", isPresented: $viewModel.saveError) {
      Button("Försök igen") {
        Task { await viewModel.retrySave() }
      }
      Button("Avbryt", role: .cancel) {}
    }
  }
}

// MARK: - Child Views
private extension IssuanceView {
  @ViewBuilder
  private var button: some View {
    switch viewModel.phase {
      case .fetchingIssuer, .authorizing, .fetchingCredential:
        ProgressView()

      case .readyToAuthorize:
        PrimaryButton("Logga in", icon: "arrow.right.circle.fill") {
          Task {
            guard let anchor else { return }
            await viewModel.beginAuthorization(anchor: anchor)
          }
        }

      case .readyToFetch:
        PrimaryButton("Försök igen") {
          Task { await viewModel.fetchCredential() }
        }

      case .done(let savedCredential, _):
        PrimaryButton("Godkänn", icon: "checkmark.circle") {
          Task { await viewModel.saveCredential(savedCredential) }
        }

      case .readyToSign, .error:
        EmptyView()
    }
  }

  private var errorPhaseView: some View {
    ErrorView(
      model: .init(
        primaryButton: .init(
          label: "Försök igen",
          accessibilityHint: "Använd knapen för att försöka igen",
          action: {
            Task { @MainActor in
              viewModel.retry(anchor: anchor)
            }
          }
        )
      )
    )
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
