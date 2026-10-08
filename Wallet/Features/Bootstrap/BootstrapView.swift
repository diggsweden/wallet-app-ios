// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct BootstrapView: View {
  @State private var viewModel = BootstrapViewModel()

  var body: some View {
    ZStack {
      Group {
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

          case let .databaseInitializationFailed(caught):
            errorView(
              caught: caught,
              allowsSignOut: false,
              title: "Det gick inte att öppna plånboken",
              subtitle: "Vi kunde inte öppna appens lagrade data. Försök igen. "
                + "Om problemet kvarstår kan du prova att installera om appen. "
                + "Då tas din lokala plånbok bort och du behöver lägga till dina handlingar igen.",
            )
        }
      }
      .transition(.opacity)
    }
    .animation(.default, value: viewModel.state.animationKey)
    .task { await viewModel.bootstrap() }
  }

  private func errorView(
    caught: CaughtError,
    allowsSignOut: Bool = true,
    title: String = "Hoppsan! Nånting gick fel",
    subtitle: String = "Vi kunde inte visa innehållet just nu, försök gärna igen senare.",
  ) -> some View {
    NavigationStack {
      ErrorView(
        model: .init(
          caughtError: caught,
          title: title,
          subtitle: subtitle,
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
