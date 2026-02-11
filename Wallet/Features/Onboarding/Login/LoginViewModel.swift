// SPDX-FileCopyrightText: 2026 diggsweden/wallet-app-ios
//
// SPDX-License-Identifier: EUPL-1.2

import AuthenticationServices
import Foundation

@MainActor
@Observable
final class LoginViewModel {
  let oauth = OAuthCoordinator()

  private var authUrl: URL? {
    var components = URLComponents(url: AppConfig.apiBaseURL, resolvingAgainstBaseURL: false)
    components?.path += "/oidc/auth"

    return components?.url ?? nil
  }

  func login(anchor: ASPresentationAnchor?) async throws -> String {
    guard let authUrl, let anchor else {
      throw OnboardingError.authFailure
    }

    let oAuthCallback = try await oauth.start(
      url: authUrl,
      callbackScheme: "wallet-app",
      anchor: anchor
    )

    guard let sessionId = oAuthCallback.queryItemValue(for: "session_id") else {
      throw OnboardingError.authFailure
    }

    return sessionId
  }
}
