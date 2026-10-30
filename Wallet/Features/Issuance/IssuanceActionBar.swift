// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import AuthenticationServices
import SwiftUI

struct IssuanceActionBar: ViewModifier {
  let viewModel: IssuanceViewModel?
  @Environment(\.webAuthenticationSession) private var webAuthSession

  func body(content: Content) -> some View {
    content.primaryActionBar(model: model)
  }

  private var model: PrimaryBarModel? {
    guard let viewModel, case let .step(step) = viewModel.state else {
      return nil
    }

    switch step {
      case .preparingToAuthorize:
        return PrimaryBarModel("Logga in") {
          Task { await viewModel.login(authenticate: webAuthSession.authenticator) }
        }

      case .awaitingCompletion, .complete:
        return PrimaryBarModel("Fortsätt") {
          Task { await viewModel.completeIssuance() }
        }

      default:
        return nil
    }
  }
}

extension View {
  func issuanceActionBar(_ viewModel: IssuanceViewModel?) -> some View {
    modifier(IssuanceActionBar(viewModel: viewModel))
  }
}
