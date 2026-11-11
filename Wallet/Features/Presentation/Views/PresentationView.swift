// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import DesignSystem
import OpenId4VCInterface
import SwiftAccessMechanism
import SwiftUI
import Trust
import UIComponents
import User

struct PresentationView: View {
  @State private var viewModel: PresentationViewModel
  @State private var path: [PresentationRoute] = []
  @State private var presentedSheet: PresentationReviewSheet?
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
    NavigationStack(path: $path) {
      content
        .animation(.default, value: viewModel.phase)
        .primaryActionBar(
          model: primaryBarModel,
          secondaryModel: secondaryBarModel,
          horizontalPadding: Constants.actionBarHorizontalPadding,
        ) {
          if case .ready = viewModel.phase {
            PresentationSharedClaimsButtonView(
              claimCount: viewModel.sharedClaimCount,
              action: {
                presentedSheet = .sharedClaims
              },
            )
          }
        }
        .defaultScreenStyle
        .navigationDestination(for: PresentationRoute.self) { route in
          destination(for: route)
            .defaultScreenStyle
            .alert("Kunde inte dela uppgifterna", isPresented: $viewModel.sendError) {
              Button("Försök igen") {}
            }
        }
        .navigationTitle("Begäran om uppgifter")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            CloseButtonView {
              router.dismiss()
            }
            .disabled(viewModel.isSending)
          }
        }
        .sheet(item: $presentedSheet, content: sheetContent)
    }
    .presentationDetents([.large])
    .presentationDragIndicator(.visible)
    .interactiveDismissDisabled(viewModel.isSending)
  }
}

private extension PresentationView {
  enum Constants {
    static let actionBarHorizontalPadding: CGFloat = 16
  }

  @ViewBuilder
  var content: some View {
    // swiftlint:disable:next closure_body_length
    ZStack {
      switch viewModel.phase {
        case .loading:
          PresentationLoadingView()
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
            optionalItems: $viewModel.optionalItems,
            requiredItems: viewModel.requiredItems,
            verifierName: viewModel.verifierUiModel?.name ?? "",
            verifierPurpose: viewModel.verifierUiModel?.localizedPurpose,
            onHeaderTap: {
              presentedSheet = .verification
            },
          )
      }
    }
    .transition(.opacity)
  }
}

private extension PresentationView {
  var primaryBarModel: PrimaryBarModel? {
    guard case .ready = viewModel.phase else {
      return nil
    }
    return PrimaryBarModel("Dela", icon: "paperplane") {
      path.append(.pin)
    }
  }

  var secondaryBarModel: PrimaryBarModel? {
    if case .error = viewModel.phase {
      return nil
    }
    return PrimaryBarModel(
      "Avbryt",
      accessibilityHint: "Avbryt begäran om uppgifter",
      action: router.dismiss,
    )
  }
}

private extension PresentationView {
  @ContentBuilder
  func sheetContent(for sheet: PresentationReviewSheet) -> some View {
    switch sheet {
      case .verification:
        EmptyView()

      case .sharedClaims:
        NavigationStack {
          PresentationSharedClaimsView(
            credentials: viewModel.sharedCredentials,
            verifierName: viewModel.verifierUiModel?.name ?? "",
          )
          .defaultScreenStyle
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
            ToolbarItem(placement: .cancellationAction) {
              CloseButtonView {
                presentedSheet = nil
              }
            }
          }
        }
        .presentationDragIndicator(.visible)
    }
  }

  @ViewBuilder
  func destination(for route: PresentationRoute) -> some View {
    switch route {
      case .pin:
        PresentationPinView(
          isLoading: viewModel.isSending
        ) { pin in
          submitPresentation(pin)
        }

      case .success:
        PresentationSuccessView {
          router.dismiss()
        }
    }
  }

  func submitPresentation(_ pin: String) {
    Task {
      guard let result = await viewModel.sendPresentation(pin) else {
        return
      }

      if let redirectUrl = result.redirectUrl {
        router.dismiss()
        openURL(redirectUrl)
      } else {
        path.append(.success)
      }
    }
  }
}
