// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import DesignSystem
import SDWebImageSwiftUI
import SwiftAccessMechanism
import SwiftUI
import WalletGatewayInterface

struct WalletSetupView: View {
  @State private var viewModel: WalletSetupViewModel

  init(
    pin: String,
    gatewayApi: GatewayApi & HSMTransport,
    onAccountCreated: @escaping @Sendable (String) async throws -> Void,
    onServerParameters: @escaping @Sendable (ServerParameters) async throws -> Void,
    onComplete: @escaping () -> Void,
  ) {
    _viewModel = State(
      wrappedValue: WalletSetupViewModel(
        service: BFFWalletSetupService(
          gatewayApi: gatewayApi,
          onAccountCreated: onAccountCreated,
          onServerParameters: onServerParameters,
        ),
        pin: pin,
        onComplete: onComplete,
      )
    )
  }

  var body: some View {
    WalletSetupContent(state: viewModel.state) {
      Task { await viewModel.retry() }
    }
    .task { await viewModel.setup() }
  }
}

struct WalletSetupContent: View {
  let state: WalletSetupState
  var onRetry: @Sendable () -> Void = {}

  var body: some View {
    VStack(spacing: 16) {
      content
    }
    .animation(.default, value: state)
  }

  @ViewBuilder
  private var content: some View {
    switch state {
      case .idle:
        EmptyView()

      case let .working(step):
        loadingIndicator(label: step.label)
          .staticAnimation(setTo: nil)

      case let .failed(_, caught):
        errorView(caught: caught)
          .transition(.blurReplace)

      case .complete:
        completeView
          .transition(.blurReplace)
    }
  }

  private func errorView(caught: CaughtError) -> some View {
    ErrorView(
      model: .init(
        caughtError: caught,
        primaryButton: .init(
          label: "Försök igen",
          accessibilityHint: "Använd knappen för att försöka igen",
          action: onRetry,
        ),
      )
    )
  }

  private var completeView: some View {
    VStack(spacing: 24) {
      Image(systemName: "checkmark.circle.fill")
        .font(.system(size: 80))
        .foregroundStyle(.green)
        .accessibilityHidden(true)
      Text("Klart!")
        .textStyle(.h2)
    }
  }

  private func loadingIndicator(label: String) -> some View {
    VStack {
      AnimatedImage(
        name: "wallet-loading-transparent.webp",
        bundle: .main,
        isAnimating: .constant(true),
      )
      .resizable()
      .indicator(.activity)
      .scaledToFit()
      .frame(width: 230)

      HStack(spacing: .zero) {
        Text(label)
          .textStyle(.bodyLarge)
        DotsLoadingView()
      }
    }
  }
}
