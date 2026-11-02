// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import AuthenticationServices
import SwiftUI
import UIComponents

struct IssuanceActionBar: ViewModifier {
  let step: IssuanceStep?
  let onLogin: (_ authenticate: @escaping WebAuthenticator) async -> Void
  let onComplete: () async -> Void
  @Environment(\.webAuthenticationSession) private var webAuthSession

  func body(content: Content) -> some View {
    content.primaryActionBar(model: model)
  }

  private var model: PrimaryBarModel? {
    switch step {
      case .preparingToAuthorize:
        return PrimaryBarModel("Logga in") {
          Task { await onLogin(webAuthSession.authenticator) }
        }

      case .awaitingCompletion, .complete:
        return PrimaryBarModel("Fortsätt") {
          Task { await onComplete() }
        }

      default:
        return nil
    }
  }
}

extension View {
  func issuanceActionBar(
    step: IssuanceStep?,
    onLogin: @escaping (_ authenticate: @escaping WebAuthenticator) async -> Void,
    onComplete: @escaping () async -> Void,
  ) -> some View {
    modifier(IssuanceActionBar(step: step, onLogin: onLogin, onComplete: onComplete))
  }
}
