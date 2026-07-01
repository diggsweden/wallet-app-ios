// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import SwiftAccessMechanism
import SwiftUI
import WalletGatewayInterface

struct PresentationView: View {
  @State private var viewModel: PresentationViewModel
  @Environment(Router.self) private var router
  @Environment(\.openURL) private var openURL

  init(
    url: URL,
    credential: SavedCredential?,
    gatewayApiClient: any GatewayApi & HSMTransport,
  ) {
    _viewModel = State(
      wrappedValue: .init(
        url: url,
        credential: credential,
        gatewayApiClient: gatewayApiClient
      )
    )
  }

  var body: some View {
    rootView
      .navigationDestination(for: PresentationRoute.self) { route in
        destination(for: route)
          .defaultScreenStyle
          .alert("Kunde inte dela uppgifterna", isPresented: $viewModel.sendError) {
            Button("Försök igen") {}
          }
      }
  }

  private func submitPresentation(_ pin: String) {
    Task {
      guard let result = await viewModel.sendPresentation(pin) else {
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
        ) { pin in
          submitPresentation(pin)
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
