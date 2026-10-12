// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import WalletMacros
import WalletNetworking

@MainActor
@Observable
final class PidSetupViewModel {
  private let onSubmit: (String) -> Void
  private(set) var caughtError: CaughtError?
  private(set) var isLoading = false

  var hasError: Bool {
    caughtError != nil
  }

  init(onSubmit: @escaping (String) -> Void) {
    self.onSubmit = onSubmit
  }

  func fetchPid(authenticate: WebAuthenticator) async {
    guard !isLoading else {
      return
    }

    isLoading = true
    defer { isLoading = false }
    caughtError = nil
    do {
      let credentialOffer =
        if let offer = await generateCredentialOffer() {
          offer
        } else {
          try await generateOfferInBrowser(authenticate)
        }

      guard let credentialOffer else {
        return
      }

      onSubmit(credentialOffer)
    } catch {
      caughtError = CaughtError(error)
    }
  }

  private func generateOfferInBrowser(_ authenticate: WebAuthenticator) async throws -> String? {
    guard
      let credentialOfferUri = try await authenticate(
        WebAuthRequest(url: AppConfig.pidIssuerUrl, callbackScheme: "openid-credential-offer")
      )
    else {
      return nil
    }

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
      let response: CredentialsOfferResponse = try? await URLSessionNetworkClient()
        .fetch(
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
