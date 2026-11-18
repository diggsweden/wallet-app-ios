// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import AuthenticationServices
import CredentialInterfaces
import DesignSystem
import OpenId4VCInterface
import SwiftUI
import UIComponents

struct IssuanceView: View {
  let viewModel: IssuanceViewModel
  let usesPinPrompt: Bool

  var body: some View {
    VStack {
      switch viewModel.state {
        case .idle:
          EmptyView()

        case .step(let step):
          issuanceStepView(step)

        case .failed(_, let error):
          ErrorView(
            model: .init(
              caughtError: error,
              primaryButton: .init(
                label: "Försök igen",
                accessibilityHint: "Välj för att försöka igen.",
                asyncAction: {
                  await viewModel.retry()
                },
              ),
            )
          )
      }
    }
    .task { await viewModel.start() }
    .toolbar { issuanceToolbar }
    .toolbar(.visible, for: .navigationBar)
  }
}

private extension IssuanceView {
  enum Constants {
    static let stepSpacing: CGFloat = 12
    static let pinRevealOffset: CGFloat = 24
  }

  @ContentBuilder
  var issuanceToolbar: some ToolbarContent {
    if shouldShowDismissButton {
      ToolbarItem(placement: .destructiveAction) {
        Button {
          Task {
            await viewModel.dismiss()
          }
        } label: {
          Image(systemName: "xmark")
            .accessibilityLabel("Avbryt")
        }
      }
    }
  }

  var shouldShowDismissButton: Bool {
    guard case .step(let step) = viewModel.state else {
      return true
    }

    switch step {
      case .awaitingCompletion, .complete:
        return false

      default:
        return true
    }
  }

  @ViewBuilder
  var issuerDisplayView: some View {
    if let issuerDisplayData = viewModel.issuerDisplayData {
      IssuerDisplayView(issuerDisplayData: issuerDisplayData)
    }
  }

  @ContentBuilder
  func issuanceStepView(_ step: IssuanceStep) -> some View {
    ZStack(alignment: .top) {
      switch step {
        case .loadingCredentialOffer, .preparingToAuthorize, .authorizing:
          VStack(spacing: Constants.stepSpacing) {
            issuerDisplayView

            if step != .preparingToAuthorize {
              ProgressView()
            }
          }

        case .awaitingPin, .authenticatingPin, .creatingKey, .signingProof, .fetchingCredential:
          pinView(isLoading: step != .awaitingPin)
            .transition(
              .asymmetric(
                insertion: .offset(y: Constants.pinRevealOffset).combined(with: .opacity),
                removal: .opacity,
              )
            )

        case let .savingCredential(credential, _, _),
          let .awaitingCompletion(credential),
          let .complete(credential):
          VStack(spacing: Constants.stepSpacing) {
            issuerDisplayView
            CredentialView(claims: credential.claims)
          }
      }
    }
    .frame(maxWidth: .infinity)
    .animation(.smooth, value: isPinStep(step))
  }

  @ViewBuilder
  func pinView(isLoading: Bool) -> some View {
    if usesPinPrompt {
      PinPromptView(
        title: "Godkänn och identifiera",
        subtitle: "Fyll i din pinkod för att begära dina personuppgifter.",
        submitLabel: "Begär personuppgifter",
        isLoading: isLoading,
        onSubmit: enterPin,
      )
    } else {
      ConfirmPinView(
        isLoading: isLoading,
        onComplete: enterPin,
      )
    }
  }

  func enterPin(_ pin: String) {
    Task { await viewModel.enterPin(pin) }
  }

  func isPinStep(_ step: IssuanceStep) -> Bool {
    switch step {
      case .awaitingPin, .authenticatingPin, .creatingKey, .signingProof, .fetchingCredential:
        true

      default:
        false
    }
  }
}
