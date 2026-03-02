// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import AuthenticationServices
import Foundation
import WalletMacrosClient

@MainActor
@Observable
final class OnboardingPidViewModel {
  private let onSubmit: (String) throws -> Void
  private let oAuthCoordinator = OAuthCoordinator()

  init(onSubmit: @escaping (String) throws -> Void) {
    self.onSubmit = onSubmit
  }

  func fetchPid(_ authAnchor: ASPresentationAnchor?) async throws {
    let credentialOffer =
      if let offer = await generateCredentialOffer() {
        offer
      } else {
        try await generateOfferInBrowser(authAnchor)
      }

    try onSubmit(credentialOffer)
  }

  private func generateOfferInBrowser(_ authAnchor: ASPresentationAnchor?) async throws -> String {
    let credentialOfferUri = try await oAuthCoordinator.start(
      url: AppConfig.pidIssuerURL,
      callbackScheme: "openid-credential-offer",
      anchor: authAnchor,
    )

    guard credentialOfferUri.queryItemValue(for: "credential_offer") != nil
    else {
      throw OnboardingError.pidFailure
    }

    return credentialOfferUri.absoluteString
  }

  private func generateCredentialOffer() async -> String? {
    let url = AppConfig.pidIssuerURL.appending(path: "issuer/credentialsOffer/generate")
    let body =
      "credentialIds=eu.europa.ec.eudi.pid_vc_sd_jwt&credentialsOfferUri=openid-credential-offer%3A%2F%2F"

    guard
      let response = try? await NetworkClient.shared.fetchJwt(
        url,
        method: .post,
        contentType: "application/x-www-form-urlencoded",
        accept: "text/html",
        body: body.utf8Data
      )
    else {
      return nil
    }

    return extractCredentialOfferURL(from: response)
  }

  private func extractCredentialOfferURL(from html: String) -> String? {
    let regex = /openid-credential-offer:\/\/[^\s"'<>]+/

    guard let match = html.firstMatch(of: regex) else {
      return nil
    }

    return String(match.output)
  }
}
