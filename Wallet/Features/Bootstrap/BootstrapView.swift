// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct BootstrapView: View {
  @State private var viewModel = BootstrapViewModel()

  var body: some View {
    ZStack {
      switch viewModel.state {
        case .loading:
          ProgressView()
            .defaultScreenStyle

        case let .accountReset(dependencies):
          AccountResetView { viewModel.acknowledgeAccountReset(dependencies: dependencies) }

        case let .ready(dependencies):
          AppRootView(appDependencies: dependencies)

        case let .error(caught):
          errorView(caught: caught)

        case let .backendCheckFailed(caught):
          errorView(caught: caught, allowsSignOut: false)
      }
    }
    .task { await viewModel.bootstrap() }
  }

  private func errorView(caught: CaughtError, allowsSignOut: Bool = true) -> some View {
    NavigationStack {
      ErrorView(
        model: .init(
          caughtError: caught,
          primaryButton: .init(
            label: "Försök igen",
            accessibilityHint: "Använd knappen för att försöka igen",
            asyncAction: viewModel.bootstrap,
          ),
          secondaryButton: allowsSignOut
            ? .init(
              label: "Logga ut",
              accessibilityHint: "Använd knappen för att logga ut",
              action: {
                Task {
                  await viewModel.signOut()
                }
              },
            ) : nil,
        )
      )
      .defaultScreenStyle
    }
  }
}
