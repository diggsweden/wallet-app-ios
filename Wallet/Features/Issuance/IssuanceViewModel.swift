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
  private var flow: any IssuanceFlow
  private let gatewayApiClient: any GatewayApi & HSMTransport
  private let hsmServerParameters: HsmServerParameters?
  private let onSaveCredential: (SavedCredential) async throws -> Void
  private var oauth = OauthCoordinator()
  private(set) var state: IssuanceState = .idle

  private(set) var issuerDisplayData: IssuerDisplay?

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
    self.flow = IssuanceSession(
      config: IssuanceConfig(
        clientId: "wallet-dev",
        redirectUri: #URL("wallet-app://authorize"),
      )
    )
  }

  func start() async {
    await resume(from: .loadingCredentialOffer)
  }

  func retry() async {
    guard case .failed(let step, _) = state else {
      return
    }
    await resume(from: step)
  }

  func login(authenticate: @escaping WebAuthenticate) async {
    guard case .step(.preparingToAuthorize) = state else {
      return
    }

    await resume(from: .authorizing(authenticate))
  }

  func enterPin(_ pin: String) async {
    guard case .step(.awaitingPin) = state else {
      return
    }

    let signer = HsmProofSigner(
      transport: gatewayApiClient,
      parameters: hsmServerParameters,
      pin: pin,
    )
    await resume(from: .authenticating(signer))
  }

  private func resume(from startStep: IssuanceStep) async {
    var current: IssuanceStep? = startStep
    while let step = current {
      state = .step(step)
      do {
        current = try await perform(step)
      } catch {
        state = .failed(at: step, CaughtError(error))
        return
      }
    }
  }

  private func perform(_ step: IssuanceStep) async throws -> IssuanceStep? {
    switch step {
      case .loadingCredentialOffer:
        try await loadOffer()
        return .preparingToAuthorize

      case .preparingToAuthorize:
        return nil

      case let .authorizing(authenticate):
        let callbackUrl = try await authenticate(flow.authorizationUrl())
        try await flow.exchangeAuthorizationCode(callbackUrl: callbackUrl)
        return .awaitingPin

      case .awaitingPin:
        return nil

      case let .authenticating(signer):
        try await signer.authenticate()
        return .creatingKey(signer)

      case let .creatingKey(signer):
        let key = try await signer.createKey()
        return .signingProof(proofKey: key, signer: signer)

      case let .signingProof(proofKey, signer):
        try await flow.createProof(
          proofKey: proofKey,
          signer: signer,
          attestations: KeyAttestationProvider(gatewayApiClient: gatewayApiClient),
        )
        return .fetchingCredential(proofKey: proofKey)

      case let .fetchingCredential(proofKey):
        let issuedCredential = try await flow.fetchCredential(proofKey: proofKey)
        return .done(issuedCredential)

      case let .done(issuedCredential):
        try await onSaveCredential(issuedCredential.credential)
        return nil
    }
  }
}

private extension IssuanceViewModel {
  private func loadOffer() async throws {
    let offer = try await flow.loadOffer(credentialOfferUri)
    issuerDisplayData = offer.issuer.map { issuer in
      IssuerDisplay(
        name: issuer.name ?? "Okänd utfärdare",
        info: issuer.info,
        imageUrl: issuer.imageUrl,
      )
    }
  }

  enum IssuanceViewModelError: LocalizedError {
    case invalidPhase(got: IssuanceStep, expected: IssuanceStep)

    var errorDescription: String? {
      switch self {
        case let .invalidPhase(passedPhase, expectedPhase):
          "Couldn't continue operation. Got \(passedPhase)" + " but expected \(expectedPhase)"
      }
    }
  }
}
