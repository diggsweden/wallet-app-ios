// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SDWebImageSwiftUI
import SwiftAccessMechanism
import SwiftUI
import WalletGatewayInterface

struct WalletSetupView: View {
  @State private var viewModel: WalletSetupViewModel

  init(
    pin: String,
    gatewayApi: GatewayApi & HSMTransport,
    onAccountCreated: @escaping @Sendable (String) async -> Void,
    onComplete: @escaping () -> Void,
  ) {
    _viewModel = State(
      wrappedValue: WalletSetupViewModel(
        service: BFFWalletSetupService(
          gatewayApi: gatewayApi,
          onAccountCreated: onAccountCreated,
        ),
        pin: pin,
        onComplete: onComplete,
      )
    )
  }

  var body: some View {
    VStack(spacing: 16) {
      switch viewModel.state {
        case .idle:
          EmptyView()

        case let .working(step):
          loadingIndicator(label: step.label)
            .staticAnimation(setTo: nil)

        case .failed(_, let error):
          WalletErrorView(
            title: "Något gick fel!",
            message: error.localizedDescription,
          ) {
            Task { await viewModel.retry() }
          }
          .transition(.blurReplace)

        case .complete:
          VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
              .font(.system(size: 80))
              .foregroundStyle(.green)
              .accessibilityHidden(true)
            Text("Klart!")
              .textStyle(.h2)
          }
          .transition(.blurReplace)
      }
    }
    .animation(.default, value: viewModel.state)
    .task { await viewModel.setup() }
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
