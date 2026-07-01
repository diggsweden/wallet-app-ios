// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import SwiftUI

struct PresentationView: View {
  @State private var viewModel: PresentationViewModel
  @Environment(Router.self) private var router
  @Environment(\.openURL) private var openURL

  init(url: URL, credential: SavedCredential?) {
    _viewModel = State(
      wrappedValue: .init(url: url, credential: credential)
    )
  }

  var body: some View {
    rootView
      .navigationDestination(for: PresentationRoute.self) { route in
        destination(for: route)
          .defaultScreenStyle
      }
      .alert("Kunde inte dela uppgifterna", isPresented: $viewModel.sendError) {
        Button("Försök igen") { submitPresentation() }
        Button("Avbryt", role: .cancel) {}
      }
  }

  private func submitPresentation() {
    Task {
      guard let result = await viewModel.sendPresentation() else {
        return
      }

      if let redirectUrl = result.redirectUrl {
        router.popToRoot()
        openURL(redirectUrl)
      } else {
        router.navigationPath.append(PresentationRoute.success)
      }
    }
  }

  @ViewBuilder
  private func destination(for route: PresentationRoute) -> some View {
    switch route {
      case .pin:
        PresentationPinView(
          isLoading: viewModel.isSending
        ) { _ in
          submitPresentation()
        }

      case .success:
        PresentationSuccessView {
          router.popToRoot()
        }
    }
  }

  @ViewBuilder
  private var rootView: some View {
    switch viewModel.phase {
      case .loading:
        ProgressView()
          .task {
            await viewModel.resolveAndMatchClaims()
          }

      case .error:
        ErrorView(
          model: .init(
            primaryButton: .init(
              label: "Försök igen",
              accessibilityHint: "Använd knappen för att försöka igen",
              action: {
                Task {
                  await viewModel.resolveAndMatchClaims()
                }
              }
            )
          )
        )

      case .ready:
        PresentationReviewView(
          requiredItems: viewModel.requiredItems,
          optionalItems: $viewModel.optionalItems,
          onConfirm: {
            router.navigationPath.append(PresentationRoute.pin)
          }
        )
    }
  }
}
