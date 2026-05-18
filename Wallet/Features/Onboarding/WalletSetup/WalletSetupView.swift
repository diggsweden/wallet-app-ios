// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SDWebImageSwiftUI
import SwiftUI
import WalletGateway

struct WalletSetupView: View {
  @State private var viewModel: WalletSetupViewModel

  init(
    pin: String,
    gatewayApiClient: GatewayApiClient,
    onAccountCreated: @escaping @Sendable (String) async -> Void,
    onComplete: @escaping () -> Void
  ) {
    self._viewModel = State(
      wrappedValue: WalletSetupViewModel(
        service: BFFWalletSetupService(
          transport: gatewayApiClient,
          gatewayApi: gatewayApiClient,
          onAccountCreated: onAccountCreated
        ),
        pin: pin,
        onComplete: onComplete
      )
    )
  }

  var body: some View {
    VStack(spacing: 16) {
      switch viewModel.state {
        case .idle:
          EmptyView()

        case let .working(step):
          AnimatedImage(
            name: "wallet-loading-transparent.webp",
            bundle: .main,
            isAnimating: .constant(true)
          )
          .resizable()
          .indicator(.activity)
          .scaledToFit()
          .frame(width: 230)
          .transition(.fade)

          HStack(spacing: .zero) {
            Text(step.label)
              .textStyle(.bodyLarge)

            DotsLoadingView()
          }

        case .failed(let step, let error):
          Text("Något gick fel vid \(step.label.lowercased())")
          Text(error.localizedDescription)
            .font(.caption)
            .foregroundStyle(.secondary)
          Button("Försök igen") {
            Task { await viewModel.retry() }
          }

        case .complete:
          Text("Klart!")
      }
    }
    .task { await viewModel.setup() }
  }
}
