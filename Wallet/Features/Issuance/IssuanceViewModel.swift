// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import AuthenticationServices
import CredentialInterfaces
import Foundation
import Issuance
import OpenId4VCInterface
import SwiftAccessMechanism
import User
import WalletGatewayInterface
import WalletMacros

@MainActor
@Observable
final class IssuanceViewModel {
  private let credentialOfferUri: String
  private var flow: (any IssuanceFlow)?
  private let gatewayApiClient: any GatewayApi & HSMTransport
  private let hsmServerParameters: HsmServerParameters?
  private let onSaveCredential: (SavedCredential) async throws -> Void
  private var oauth = OauthCoordinator()

  private(set) var issuerDisplayData: IssuerDisplay?
  private(set) var phase: IssuancePhase = .fetchingIssuer
  private(set) var pinAttempt = 0

  var pinError = false
  var saveError = false

  init(
    credentialOfferUri: String,
    gatewayApiClient: any GatewayApi & HSMTransport,
    hsmServerParameters: HsmServerParameters?,
    onSaveCredential: @escaping (SavedCredential) async throws -> Void,
  ) {
    self.credentialOfferUri = credentialOfferUri
    self.gatewayApiClient = gatewayApiClient
    self.hsmServerParameters = hsmServerParameters
    self.onSaveCredential = onSaveCredential
  }

  func start() async {
    phase = .fetchingIssuer
    let flow = IssuanceSession(
      config: IssuanceConfig(
        clientId: "wallet-dev",
        redirectUri: #URL("wallet-app://authorize"),
      )
    )
    self.flow = flow
    do {
      let offer = try await flow.loadOffer(credentialOfferUri)
      issuerDisplayData = offer.issuer.map { issuer in
        IssuerDisplay(
          name: issuer.name ?? "Okänd utfärdare",
          info: issuer.info,
          imageUrl: issuer.imageUrl,
        )
      }
      phase = .readyToAuthorize
    } catch {
      phase = .error(.start, CaughtError(error))
    }
  }

  func beginAuthorization(anchor: ASPresentationAnchor) async {
    guard let flow, case .readyToAuthorize = phase else {
      return
    }

    phase = .authorizing
    do {
      let authorizationUrl = try await flow.authorizationUrl()
      let callbackUrl = try await oauth.start(
        url: authorizationUrl,
        callbackScheme: "wallet-app",
        anchor: anchor,
      )
      try await flow.exchangeAuthorizationCode(callbackUrl: callbackUrl)
      phase = .readyToSign
    } catch {
      if error.isWebAuthCancellation {
        phase = .readyToAuthorize
      } else {
        phase = .error(.authorize, CaughtError(error))
      }
    }
  }

  func createProof(with pin: String) async {
    guard let flow, case .readyToSign = phase else {
      return
    }

    do {
      let signer = HsmProofSigner(
        transport: gatewayApiClient,
        parameters: hsmServerParameters,
        pin: pin,
      )
      try await flow.createProof(
        signer: signer,
        attestations: WalletUnitAttestationProvider(gatewayApiClient: gatewayApiClient),
      )
      phase = .readyToFetch
      await fetchCredential()
    } catch {
      pinError = true
      pinAttempt += 1
    }
  }

  func fetchCredential() async {
    guard let flow, case .readyToFetch = phase else {
      return
    }

    phase = .fetchingCredential
    do {
      let issued = try await flow.fetchCredential()
      phase = .done(issued.credential, issued.claims)
    } catch {
      phase = .error(.fetchCredential, CaughtError(error))
    }
  }

  func saveCredential(_ credential: SavedCredential) async {
    do {
      try await onSaveCredential(credential)
    } catch {
      saveError = true
    }
  }

  func retrySave() async {
    guard case .done(let credential, _) = phase else {
      return
    }

    await saveCredential(credential)
  }

  func retry(anchor: ASPresentationAnchor?) {
    guard case .error(let recovery, _) = phase else {
      return
    }

    Task {
      switch recovery {
        case .start:
          await start()

        case .authorize:
          guard let anchor else { return }
          phase = .readyToAuthorize
          await beginAuthorization(anchor: anchor)

        case .fetchCredential:
          phase = .readyToFetch
          await fetchCredential()
      }
    }
  }
}
