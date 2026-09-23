// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

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
  private let actions: IssuanceActions
  private(set) var state: IssuanceState = .idle
  private var flowTask: Task<Void, Never>?

  private(set) var issuerDisplayData: IssuerDisplay?
  private let makeSigner: (_ pin: String) -> any ProofKeyManager

  init(
    credentialOfferUri: String,
    gatewayApiClient: any GatewayApi & HSMTransport,
    hsmServerParameters: HsmServerParameters?,
    actions: IssuanceActions,
    issuanceFlow: any IssuanceFlow = IssuanceSession(
      config: IssuanceConfig(
        clientId: "wallet-dev",
        redirectUri: #URL("wallet-app://authorize"),
      )
    ),
    makeSigner: ((_ pin: String) -> any ProofKeyManager)? = nil,
  ) {
    self.credentialOfferUri = credentialOfferUri
    self.gatewayApiClient = gatewayApiClient
    self.actions = actions
    self.flow = issuanceFlow
    self.makeSigner =
      makeSigner ?? { pin in
        HsmProofSigner(transport: gatewayApiClient, parameters: hsmServerParameters, pin: pin)
      }
  }

  func start() async {
    await resume(from: .loadingCredentialOffer)
  }

  func retry() async {
    guard case .failed(let step, _) = state else {
      return
    }

    await resume(from: step.retryStep)
  }

  func login(authenticate: @escaping WebAuthenticator) async {
    guard case .step(.preparingToAuthorize) = state else {
      return
    }

    await resume(from: .authorizing(authenticate))
  }

  func enterPin(_ pin: String) async {
    guard case .step(.awaitingPin) = state else {
      return
    }

    await resume(from: .authenticatingPin(makeSigner(pin)))
  }

  func completeIssuance() async {
    guard case let .step(.awaitingCompletion(credential)) = state else {
      return
    }

    await resume(from: .complete(credential))
  }

  func dismiss() async {
    flowTask?.cancel()
    await actions.onDismiss()
    await flowTask?.value

    let currentStep: IssuanceStep? =
      switch state {
        case let .step(step),
          let .failed(at: step, _):
          step

        case .idle: nil
      }

    if let currentStep,
      let (keyId, store) = currentStep.pendingKey
    {
      try? await store.deleteKey(id: keyId)
    }
  }

  private func resume(from startStep: IssuanceStep) async {
    let task = Task { await run(from: startStep) }
    flowTask = task
    await withTaskCancellationHandler {
      await task.value
    } onCancel: {
      task.cancel()
    }
  }

  private func run(from startStep: IssuanceStep) async {
    var current: IssuanceStep? = startStep
    while let step = current {
      state = .step(step)
      guard !Task.isCancelled else {
        return
      }

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
      case .preparingToAuthorize, .awaitingPin, .awaitingCompletion:
        return nil

      case .loadingCredentialOffer:
        try await loadOffer()
        return .preparingToAuthorize

      case let .authorizing(authenticate):
        guard
          let callbackUrl = try await authenticate(
            WebAuthRequest(url: flow.authorizationUrl(), callbackScheme: "wallet-app")
          )
        else {
          return .preparingToAuthorize
        }

        try await flow.exchangeAuthorizationCode(callbackUrl: callbackUrl)
        return .awaitingPin

      case let .authenticatingPin(signer):
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
        return .fetchingCredential(
          proofKey: proofKey,
          signer: signer,
        )

      case let .fetchingCredential(proofKey, signer):
        let issuedCredential = try await flow.fetchCredential(proofKey: proofKey)
        return .savingCredential(issuedCredential, proofKey: proofKey, signer: signer)

      case let .savingCredential(issuedCredential, _, _):
        try await actions.onSaveCredential(issuedCredential.credential)
        return .awaitingCompletion(issuedCredential)

      case .complete:
        try await actions.onComplete()
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
