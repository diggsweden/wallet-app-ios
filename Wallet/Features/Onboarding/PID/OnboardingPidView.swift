// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import JOSESwift
import SwiftUI
import WalletMacrosClient

struct OnboardingPidView: View {
  private var viewModel: OnboardingPidViewModel
  @Environment(ToastViewModel.self) private var toastViewModel
  @Environment(\.authPresentationAnchor) private var anchor

  init(
    walletId: String,
    gatewayAPIClient: GatewayAPI,
    onSubmit: @escaping (String) throws -> Void
  ) {
    viewModel = OnboardingPidViewModel(
      walletId: walletId,
      gatewayAPIClient: gatewayAPIClient,
      onSubmit: onSubmit
    )
  }

  var body: some View {
    VStack(spacing: 0) {
      Image(.penPaper)
        .resizable()
        .frame(width: 92, height: 92)
        .padding(.bottom, 50)

      VStack(alignment: .leading, spacing: 12) {
        Text("Varför?")
          .textStyle(.h5)

        Text(
          "För att kunna använda plånboken behöver vi hämta uppgifter om dig. Uppgifterna som hämtas används som ett id-kort."
        )
        .padding(.bottom, 8)

        InlineLink("Läs mer om de uppgifter vi hämtar", url: #URL("https://wallet.sandbox.digg.se"))
      }

      Spacer()

      button
    }
  }

  @ViewBuilder
  private var button: some View {
    PrimaryButton("Hämta personuppgifter", icon: "arrow.up.forward.app") {
      Task {
        do {
          try await viewModel.fetchPid(anchor)
        } catch {
          toastViewModel.showError("Något gick fel, försök igen!")
        }
      }
    }
  }
}

#Preview {
  OnboardingPidView(walletId: "", gatewayAPIClient: GatewayAPIMock()) { _ in }.themed.withToast
}
