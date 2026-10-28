// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import DesignSystem
import OpenId4VCInterface
import SwiftAccessMechanism
import SwiftUI
import Trust
import User

struct PresentationView: View {
  @State private var viewModel: PresentationViewModel
  @Environment(Router.self) private var router
  @Environment(\.openURL) private var openURL
  @Environment(\.theme) private var theme

  init(
    url: URL,
    credentials: [SavedCredential],
    hsmTransport: any HSMTransport,
    hsmServerParameters: HsmServerParameters?,
    trustStore: any TrustStoreInterface,
  ) {
    _viewModel = State(
      wrappedValue: .init(
        url: url,
        credentials: credentials,
        hsmTransport: hsmTransport,
        hsmServerParameters: hsmServerParameters,
        trustStore: trustStore,
      )
    )
  }

  var body: some View {
    // swiftlint:disable:next closure_body_length
    Group {
      switch viewModel.phase {
        case .loading:
          ProgressView()
            .task {
              await viewModel.resolveAndMatchClaims()
            }

        case let .error(caught):
          ErrorView(
            model: .init(
              caughtError: caught,
              primaryButton: .init(
                label: "Försök igen",
                accessibilityHint: "Använd knappen för att försöka igen",
                action: {
                  Task {
                    await viewModel.resolveAndMatchClaims()
                  }
                },
              ),
            )
          )
          .padding(.horizontal, theme.horizontalPadding)

        case .ready:
          PresentationReviewView(
            requiredItems: viewModel.requiredItems,
            optionalItems: $viewModel.optionalItems,
            verifierName: viewModel.verifierUiModel?.name ?? "",
            onConfirm: {
              router.navigationPath.append(PresentationRoute.pin)
            },
          )
      }
    }
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
}
