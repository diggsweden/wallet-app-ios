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

    await resume(from: .creatingKey(pin: pin))
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

      case let .creatingKey(pin):
        let key = try await createKey(pin: pin)
        return .signingProof(proofKey: key, pin: pin)

      case let .signingProof(proofKey, pin):
        try await signProof(with: proofKey, pin: pin)
        return .fetchingCredential

      case .fetchingCredential:
        let issuedCredential = try await flow.fetchCredential()
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

  private func signProof(with key: ProofKey, pin: String) async throws {
    let signer = HsmProofSigner(
      transport: gatewayApiClient,
      parameters: hsmServerParameters,
      pin: pin,
    )
    let key = try await signer.createKey()
    try await flow.createProof(
      proofKey: key,
      signer: signer,
      attestations: KeyAttestationProvider(gatewayApiClient: gatewayApiClient),
    )
  }

  func createKey(pin: String) async throws -> ProofKey {
    let hsmProofSigner = HsmProofSigner(
      transport: gatewayApiClient,
      parameters: hsmServerParameters,
      pin: pin,
    )

    return try await hsmProofSigner.createKey()
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
