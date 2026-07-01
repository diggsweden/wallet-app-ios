// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import DesignSystem
import SwiftUI
import WalletMacros

struct PidSetupView: View {
  @State private var viewModel: PidSetupViewModel
  @Environment(\.authPresentationAnchor) private var anchor

  init(onSubmit: @escaping (String) -> Void) {
    _viewModel = State(wrappedValue: PidSetupViewModel(onSubmit: onSubmit))
  }

  var body: some View {
    ZStack {
      if viewModel.hasError {
        errorView
          .transition(.opacity)
      } else {
        content
          .transition(.opacity)
      }
    }
    .animation(.default, value: viewModel.hasError)
  }

  private var content: some View {
    VStack(spacing: 0) {
      Image(.penPaper)
        .resizable()
        .frame(width: 92, height: 92)
        .padding(.bottom, 50)
        .accessibilityHidden(true)

      VStack(alignment: .leading, spacing: 12) {
        Text("Varför?")
          .textStyle(.h5)

        Text(
          // swiftlint:disable:next line_length
          "För att kunna använda plånboken behöver vi hämta uppgifter om dig. Uppgifterna som hämtas används som ett id-kort."
        )
        .padding(.bottom, 8)

        InlineLink("Läs mer om de uppgifter vi hämtar", url: #URL("https://wallet.sandbox.digg.se"))
      }

      Spacer()

      button
    }
  }

  private var errorView: some View {
    ErrorView(
      model: .init(
        primaryButton: .init(
          label: "Försök igen",
          accessibilityHint: "Använd knappen för att försöka igen",
          action: {
            Task { await viewModel.fetchPid(anchor) }
          }
        )
      )
    )
  }

  @ViewBuilder
  private var button: some View {
    PrimaryButton("Hämta personuppgifter", icon: "arrow.up.forward.app") {
      Task { await viewModel.fetchPid(anchor) }
    }
  }
}

#Preview {
  PidSetupView { _ in }.themed
}
