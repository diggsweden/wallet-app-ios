// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import AuthenticationServices
import Foundation
import WalletMacros

@MainActor
@Observable
final class PidSetupViewModel {
  private let onSubmit: (String) -> Void
  private let oAuthCoordinator = OauthCoordinator()

  private(set) var caughtError: CaughtError?

  var hasError: Bool {
    caughtError != nil
  }

  init(onSubmit: @escaping (String) -> Void) {
    self.onSubmit = onSubmit
  }

  func fetchPid(_ authAnchor: ASPresentationAnchor?) async {
    caughtError = nil
    do {
      let credentialOffer =
        if let offer = await generateCredentialOffer() {
          offer
        } else {
          try await generateOfferInBrowser(authAnchor)
        }

      onSubmit(credentialOffer)
    } catch {
      if !error.isWebAuthCancellation {
        caughtError = CaughtError(error)
      }
    }
  }

  private func generateOfferInBrowser(_ authAnchor: ASPresentationAnchor?) async throws -> String {
    let credentialOfferUri = try await oAuthCoordinator.start(
      url: AppConfig.pidIssuerUrl,
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
    let url = AppConfig.pidIssuerUrl.appending(path: "issuer/credentialsOffer/create")
    let body = #"{"credentialIds":["eu.europa.ec.eudi.pid_vc_sd_jwt"]}"#

    guard
      let response: CredentialsOfferResponse = try? await NetworkClient.fetch(
        url,
        method: .post,
        body: body.utf8Data,
      )
    else {
      return nil
    }

    return response.credentialsOffer
  }
}

private struct CredentialsOfferResponse: Decodable {
  let credentialsOffer: String?
}
