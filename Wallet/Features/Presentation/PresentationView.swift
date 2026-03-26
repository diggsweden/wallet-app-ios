// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct PresentationView: View {
  @State private var viewModel: PresentationViewModel
  @Environment(Router.self) private var router
  @Environment(ToastViewModel.self) private var toastViewModel
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
      .onChange(of: viewModel.error) { _, error in
        guard let error else { return }
        toastViewModel.showError(error.message)
      }
  }

  @ViewBuilder
  private func destination(for route: PresentationRoute) -> some View {
    switch route {
      case .pin:
        PresentationPinView(
          isLoading: viewModel.isSending
        ) { _ in
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
        PresentationErrorView(
          onRetry: {
            Task {
              await viewModel.resolveAndMatchClaims()
            }
          },
          onDismiss: {
            router.pop()
          }
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
