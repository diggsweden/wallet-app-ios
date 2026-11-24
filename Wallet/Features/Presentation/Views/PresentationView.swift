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
  @State private var presentedSheet: PresentationReviewSheet?
  @Environment(Router.self) private var router
  @Environment(\.openURL) private var openURL
  @Environment(\.theme) private var theme
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

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
    NavigationStack {
      ZStack {
        content
      }
      .animation(.smooth, value: viewModel.phase)
      .primaryActionBar(
        model: primaryBarModel,
        secondaryModel: secondaryBarModel,
        horizontalPadding: Constants.actionBarHorizontalPadding,
      ) {
        if viewModel.phase == .review {
          PresentationSharedClaimsButtonView(
            claimCount: viewModel.sharedClaimCount,
            action: {
              presentedSheet = .sharedClaims
            },
          )
        }
      }
      .defaultScreenStyle
      .alert("Kunde inte dela uppgifterna", isPresented: $viewModel.sendError) {
        Button("Försök igen") {}
      }
      .navigationTitle(Text(navigationTitle))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        if showsToolbarButton {
          ToolbarItem(placement: .cancellationAction) {
            toolbarButtonView
          }
        }
      }
      .sheet(item: $presentedSheet, content: sheetContent)
    }
    .presentationDetents([.large])
    .presentationDragIndicator(isInteractiveDismissEnabled ? .visible : .hidden)
    .interactiveDismissDisabled(!isInteractiveDismissEnabled)
  }
}

private extension PresentationView {
  enum Constants {
    static let actionBarHorizontalPadding: CGFloat = 16
    static let pinRevealOffset: CGFloat = 24
  }

  var pinTransition: AnyTransition {
    guard !reduceMotion else {
      return .opacity
    }

    return .asymmetric(
      insertion: .offset(y: Constants.pinRevealOffset).combined(with: .opacity),
      removal: .opacity,
    )
  }

  @ViewBuilder
  var content: some View {
    // swiftlint:disable:next closure_body_length
    Group {
      switch viewModel.phase {
        case .loading:
          PresentationLoadingView(
            title: "Kontrollerar begäran",
            subtitle: "Plånboken kontrollerar mottagaren mot tillitsregistret.",
          )
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
                  Task { @MainActor in
                    viewModel.retry()
                  }
                },
              ),
            )
          )
          .padding(.horizontal, theme.horizontalPadding)

        case .review:
          PresentationReviewView(
            optionalItems: $viewModel.optionalItems,
            requiredItems: viewModel.requiredItems,
            verifierName: viewModel.verifierUiModel?.name ?? "",
            verifierPurpose: viewModel.verifierUiModel?.localizedPurpose,
            onHeaderTap: {
              presentedSheet = .verification
            },
          )

        case .pin:
          PresentationPinView(
            verifierName: viewModel.verifierUiModel?.name ?? "",
            sharedClaimCount: viewModel.sharedClaimCount,
            onPinEntered: submitPresentation,
          )
          .transition(pinTransition)

        case .sending:
          ProgressView()

        case .success:
          PresentationSuccessView(
            verifierName: viewModel.verifierUiModel?.name ?? "",
            verifierLogo: nil,
            onShowSharedClaims: { presentedSheet = .sharedClaims },
          )
      }
    }
    .transition(.blurReplace)
  }

  @ViewBuilder
  var toolbarButtonView: some View {
    if viewModel.phase == .pin {
      Button(
        "Tillbaka",
        systemImage: "chevron.backward",
        action: viewModel.goBack,
      )
    } else {
      CloseButtonView(action: router.dismiss)
    }
  }
}

private extension PresentationView {
  var isInteractiveDismissEnabled: Bool {
    viewModel.phase == .success
  }

  var showsToolbarButton: Bool {
    switch viewModel.phase {
      case .sending, .success:
        false

      default:
        true
    }
  }

  var sendingSubtitle: LocalizedStringResource {
    let verifierName = viewModel.verifierUiModel?.name ?? ""
    return "Skickar \(viewModel.sharedClaimCount) uppgifter till \(verifierName)."
  }

  var navigationTitle: LocalizedStringResource {
    switch viewModel.phase {
      case .loading, .error, .review:
        "Begäran om uppgifter"

      case .pin, .sending:
        "Godkänn delning"

      case .success:
        "Delat"
    }
  }

  var primaryBarModel: PrimaryBarModel? {
    switch viewModel.phase {
      case .review:
        PrimaryBarModel("Dela", icon: "paperplane", action: viewModel.share)

      case .success:
        PrimaryBarModel("Klar", action: router.dismiss)

      default:
        nil
    }
  }

  var secondaryBarModel: PrimaryBarModel? {
    switch viewModel.phase {
      case .loading, .review:
        PrimaryBarModel(
          "Avbryt",
          accessibilityHint: "Avbryt begäran om uppgifter",
          action: router.dismiss,
        )

      default:
        nil
    }
  }
}

private extension PresentationView {
  func sheetContent(for sheet: PresentationReviewSheet) -> some View {
    NavigationStack {
      Group {
        switch sheet {
          case .verification:
            PresentationVerificationView(
              verifierName: viewModel.verifierUiModel?.name ?? "",
              verifierPurpose: viewModel.verifierUiModel?.localizedPurpose,
              isEncrypted: viewModel.isEncrypted,
            )

          case .sharedClaims:
            PresentationSharedClaimsView(
              credentials: viewModel.sharedCredentials,
              verifierName: viewModel.verifierUiModel?.name ?? "",
              hasBeenShared: viewModel.phase == .success,
            )
        }
      }
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

  func submitPresentation(_ pin: String) {
    Task {
      if let redirectUrl = await viewModel.sendPresentation(pin) {
        router.dismiss()
        openURL(redirectUrl)
      }
    }
  }
}
