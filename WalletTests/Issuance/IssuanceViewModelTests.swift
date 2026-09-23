// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

// swiftlint:disable file_length

import CredentialInterfaces
import Foundation
import OpenId4VCInterface
import Testing
import WalletMacros

@testable import WalletDemo

private extension IssuanceState {
  var currentStep: IssuanceStep? {
    if case .step(let step) = self { step } else { nil }
  }

  var failedStep: IssuanceStep? {
    if case .failed(let step, _) = self { step } else { nil }
  }
}

// MARK: - Tests

@MainActor
// swiftlint:disable:next type_body_length
struct IssuanceViewModelTests {
  private static let callbackUrl = #URL("wallet-app://authorize?code=abc&state=xyz")

  private let recorder = IssuanceRecorder()

  private func makeViewModel(
    flow: FakeIssuanceFlow = FakeIssuanceFlow(),
    signerFailures: Set<FakeProofKeyManager.Operation> = [],
    onSave: ((SavedCredential) async throws -> Void)? = nil,
    onDismiss: @escaping @MainActor () -> Void = {},
  ) -> IssuanceViewModel {
    let recorder = recorder
    return IssuanceViewModel(
      credentialOfferUri: "openid-credential-offer://?credential_offer_uri=x",
      gatewayApiClient: FakeGateway(),
      hsmServerParameters: nil,
      actions: .init(
        onSaveCredential: { credential in
          recorder.savedCredentials.append(credential)
          try await onSave?(credential)
        },
        onComplete: { recorder.completeCount += 1 },
        onDismiss: onDismiss,
      ),
      issuanceFlow: flow,
      makeSigner: { pin in
        // Only the first signer fails, so a retry with a new PIN can succeed.
        let signer = FakeProofKeyManager(
          failingOnce: recorder.signers.isEmpty ? signerFailures : []
        )
        recorder.pins.append(pin)
        recorder.signers.append(signer)
        return signer
      },
    )
  }

  private func authenticate() -> WebAuthenticate {
    let recorder = recorder
    return { url in
      recorder.authorizationUrls.append(url)
      return Self.callbackUrl
    }
  }

  /// Drives the view model to the PIN prompt.
  private func awaitingPin(_ viewModel: IssuanceViewModel) async {
    await viewModel.start()
    await viewModel.login(authenticate: authenticate())
  }

  // MARK: Offer and authorization

  @Test
  func startLoadsTheOfferAndWaitsForLogin() async {
    let flow = FakeIssuanceFlow()
    let viewModel = makeViewModel(flow: flow)

    await viewModel.start()

    #expect(viewModel.state.currentStep == .preparingToAuthorize)
    #expect(viewModel.issuerDisplayData?.name == "Issuer")
    #expect(viewModel.issuerDisplayData?.info == "Info")
    #expect(await flow.calls == [.loadOffer])
  }

  @Test
  func failedOfferLoadCanBeRetried() async {
    let flow = FakeIssuanceFlow(failingOnce: [.loadOffer])
    let viewModel = makeViewModel(flow: flow)

    await viewModel.start()
    #expect(viewModel.state.failedStep == .loadingCredentialOffer)

    await viewModel.retry()
    #expect(viewModel.state.currentStep == .preparingToAuthorize)
    #expect(await flow.calls == [.loadOffer, .loadOffer])
  }

  @Test
  func loginAuthorizesWithTheCallbackAndAsksForPin() async {
    let flow = FakeIssuanceFlow()
    let viewModel = makeViewModel(flow: flow)

    await awaitingPin(viewModel)

    #expect(viewModel.state.currentStep == .awaitingPin)
    #expect(recorder.authorizationUrls == [FakeIssuanceFlow.authorizationUrl])
    #expect(await flow.callbackUrls == [Self.callbackUrl])
    #expect(recorder.signers.isEmpty, "no HSM session is opened before the PIN is entered")
  }

  @Test
  func failedAuthorizationReturnsToLogin() async {
    let flow = FakeIssuanceFlow(failingOnce: [.exchangeAuthorizationCode])
    let viewModel = makeViewModel(flow: flow)

    await awaitingPin(viewModel)
    #expect(viewModel.state.failedStep == .authorizing(authenticate()))

    await viewModel.retry()
    #expect(viewModel.state.currentStep == .preparingToAuthorize)
  }

  @Test
  func cancelledLoginReturnsToLoginWithoutFailing() async {
    let flow = FakeIssuanceFlow()
    let viewModel = makeViewModel(flow: flow)
    await viewModel.start()

    await viewModel.login { _ in nil }

    #expect(viewModel.state.currentStep == .preparingToAuthorize)
    #expect(!(await flow.calls).contains(.exchangeAuthorizationCode))
  }

  @Test
  func loginIsIgnoredBeforeTheOfferIsLoaded() async {
    let flow = FakeIssuanceFlow()
    let viewModel = makeViewModel(flow: flow)

    await viewModel.login(authenticate: authenticate())

    #expect(viewModel.state.currentStep == nil)
    #expect(await flow.calls.isEmpty)
  }

  // MARK: Key creation and credential

  @Test
  func pinCreatesANewKeyThatSignsTheProofAndBindsTheCredential() async throws {
    let flow = FakeIssuanceFlow()
    let viewModel = makeViewModel(flow: flow)
    await awaitingPin(viewModel)

    await viewModel.enterPin("123456")

    let signer = try #require(recorder.signers.first)
    let key = try #require(await signer.createdKeys.first)
    #expect(recorder.pins == ["123456"])
    #expect(await signer.authenticateCount == 1)
    #expect(await signer.createKeyCount == 1)
    #expect(await flow.proofKeys == [key])
    #expect(await flow.fetchKeys == [key])
    let signedBySessionSigner = await flow.proofSigners.first.map { $0 as AnyObject } === signer
    let attestsThroughGateway = await flow.attestationProviders.first is KeyAttestationProvider
    #expect(signedBySessionSigner)
    #expect(attestsThroughGateway)
    #expect(recorder.savedCredentials.map(\.keyId) == [key.id.rawValue])
    #expect(
      viewModel.state.currentStep
        == .savingCredential(
          .bound(
            to: key
          ),
          proofKey: key,
          signer: signer,
        )
    )
  }

  @Test
  func stepsRunInOrderAfterThePin() async {
    let flow = FakeIssuanceFlow()
    let viewModel = makeViewModel(flow: flow)
    await awaitingPin(viewModel)

    await viewModel.enterPin("123456")

    #expect(
      await flow.calls == [
        .loadOffer, .authorizationUrl, .exchangeAuthorizationCode, .createProof, .fetchCredential,
      ]
    )
  }

  @Test
  func wrongPinAsksForThePinAgainWithoutCreatingAKey() async throws {
    let flow = FakeIssuanceFlow()
    let viewModel = makeViewModel(flow: flow, signerFailures: [.authenticate])
    await awaitingPin(viewModel)

    await viewModel.enterPin("000000")
    let failedSigner = try #require(recorder.signers.first)
    #expect(viewModel.state.failedStep == .authenticatingPin(failedSigner))
    #expect(await failedSigner.createKeyCount == 0)

    await viewModel.retry()
    #expect(viewModel.state.currentStep == .awaitingPin)

    await viewModel.enterPin("123456")
    #expect(recorder.pins == ["000000", "123456"])
    #expect(recorder.signers.count == 2)
    let signer = try #require(recorder.signers.last)
    let key = try #require(await signer.createdKeys.first)
    #expect(await flow.proofKeys == [key])
    #expect(recorder.savedCredentials.map(\.keyId) == [key.id.rawValue])
  }

  @Test
  func failedKeyCreationRetriesKeyCreationWithTheSameSession() async throws {
    let flow = FakeIssuanceFlow()
    let viewModel = makeViewModel(flow: flow, signerFailures: [.createKey])
    await awaitingPin(viewModel)

    await viewModel.enterPin("123456")
    let signer = try #require(recorder.signers.first)
    #expect(viewModel.state.failedStep == .creatingKey(signer))
    #expect(await flow.proofKeys.isEmpty)

    await viewModel.retry()
    #expect(recorder.signers.count == 1)
    #expect(await signer.authenticateCount == 1)
    #expect(await signer.createKeyCount == 2)
    let key = try #require(await signer.createdKeys.first)
    #expect(recorder.savedCredentials.map(\.keyId) == [key.id.rawValue])
  }

  @Test
  func failedProofRetriesWithTheSameKey() async throws {
    let flow = FakeIssuanceFlow(failingOnce: [.createProof])
    let viewModel = makeViewModel(flow: flow)
    await awaitingPin(viewModel)

    await viewModel.enterPin("123456")
    let signer = try #require(recorder.signers.first)
    let key = try #require(await signer.createdKeys.first)
    #expect(viewModel.state.failedStep == .signingProof(proofKey: key, signer: signer))

    await viewModel.retry()
    #expect(await signer.createKeyCount == 1)
    #expect(await flow.proofKeys == [key, key])
    #expect(await flow.fetchKeys == [key])
    #expect(recorder.savedCredentials.map(\.keyId) == [key.id.rawValue])
  }

  @Test
  func failedFetchRecreatesProofWithTheSameKeyAndSigner() async throws {
    let flow = FakeIssuanceFlow(failingOnce: [.fetchCredential])
    let viewModel = makeViewModel(flow: flow)
    await awaitingPin(viewModel)

    await viewModel.enterPin("123456")
    let signer = try #require(recorder.signers.first)
    let key = try #require(await signer.createdKeys.first)
    #expect(viewModel.state.failedStep == .fetchingCredential(proofKey: key, signer: signer))
    #expect(recorder.savedCredentials.isEmpty)

    await viewModel.retry()
    #expect(recorder.signers.count == 1)
    #expect(await signer.authenticateCount == 1)
    #expect(await signer.createKeyCount == 1)
    #expect(await flow.proofKeys == [key, key])
    let proofSigners = await flow.proofSigners
    #expect(proofSigners.count == 2)
    #expect(proofSigners.allSatisfy { $0 as AnyObject === signer })
    #expect(
      await flow.calls == [
        .loadOffer, .authorizationUrl, .exchangeAuthorizationCode,
        .createProof, .fetchCredential, .createProof, .fetchCredential,
      ]
    )
    #expect(await flow.fetchKeys == [key, key])
    #expect(recorder.savedCredentials.map(\.keyId) == [key.id.rawValue])
  }

  @Test
  func failedSaveCanBeRetriedWithoutFetchingAgain() async throws {
    let flow = FakeIssuanceFlow()
    let recorder = recorder
    let viewModel = makeViewModel(flow: flow) { _ in
      if recorder.savedCredentials.count == 1 {
        throw FakeError.intentional
      }
    }
    await awaitingPin(viewModel)

    await viewModel.enterPin("123456")
    let signer = try #require(recorder.signers.first)
    let key = try #require(await signer.createdKeys.first)
    #expect(
      viewModel.state.failedStep
        == .savingCredential(
          .bound(to: key),
          proofKey: key,
          signer: signer,
        )
    )

    await viewModel.retry()
    #expect(
      viewModel.state.currentStep
        == .savingCredential(
          .bound(to: key),
          proofKey: key,
          signer: signer,
        )
    )
    #expect(await flow.fetchKeys == [key])
    #expect(recorder.savedCredentials.count == 2)
  }

  @Test
  func pinIsIgnoredBeforeAuthorization() async {
    let viewModel = makeViewModel()
    await viewModel.start()

    await viewModel.enterPin("123456")

    #expect(viewModel.state.currentStep == .preparingToAuthorize)
    #expect(recorder.signers.isEmpty)
  }

  // MARK: Completion

  @Test
  func completeIssuanceFinishesAfterTheCredentialIsSaved() async throws {
    let viewModel = makeViewModel()
    await awaitingPin(viewModel)
    await viewModel.enterPin("123456")
    let key = try #require(await recorder.signers.first?.createdKeys.first)
    #expect(recorder.completeCount == 0, "saving waits for the user before completing")

    await viewModel.completeIssuance()

    #expect(recorder.completeCount == 1)
    #expect(viewModel.state.currentStep == .complete(.bound(to: key)))
  }

  @Test
  func completeIssuanceIsIgnoredBeforeTheCredentialIsSaved() async {
    let viewModel = makeViewModel()
    await awaitingPin(viewModel)

    await viewModel.completeIssuance()

    #expect(recorder.completeCount == 0)
    #expect(viewModel.state.currentStep == .awaitingPin)
  }

  // MARK: Dismissal

  @Test
  func completeIssuanceWaitsForAnInFlightSave() async {
    let gate = Gate()
    let viewModel = makeViewModel(onSave: { _ in await gate.pass() })
    await awaitingPin(viewModel)

    async let issuing: Void = viewModel.enterPin("123456")
    await gate.reached()
    await viewModel.completeIssuance()
    #expect(recorder.completeCount == 0)
    #expect(!viewModel.credentialSaved)

    gate.open()
    await issuing
    #expect(viewModel.credentialSaved)
    await viewModel.completeIssuance()
    #expect(recorder.completeCount == 1)
  }

  @Test
  func dismissAfterSaveKeepsTheCredentialKey() async throws {
    let viewModel = makeViewModel()
    await awaitingPin(viewModel)
    await viewModel.enterPin("123456")
    let signer = try #require(recorder.signers.first)

    await viewModel.dismiss()

    #expect(await signer.deletedKeyIds.isEmpty)
  }

  @Test
  func dismissAfterFailedSaveDeletesTheKey() async throws {
    let viewModel = makeViewModel { _ in throw FakeError.intentional }
    await awaitingPin(viewModel)
    await viewModel.enterPin("123456")
    let signer = try #require(recorder.signers.first)
    let key = try #require(await signer.createdKeys.first)

    await viewModel.dismiss()

    #expect(await signer.deletedKeyIds == [key.id])
  }

  // Each test below opens the gate from `onDismiss`, so the running step
  // finishes only after the flow has been cancelled.

  @Test
  func dismissDuringFetchStopsBeforeSavingAndDeletesTheKey() async throws {
    let gate = Gate()
    let flow = FakeIssuanceFlow(fetchGate: gate)
    let viewModel = makeViewModel(flow: flow, onDismiss: gate.open)
    await awaitingPin(viewModel)

    async let issuing: Void = viewModel.enterPin("123456")
    await gate.reached()
    await viewModel.dismiss()
    await issuing

    let signer = try #require(recorder.signers.first)
    let key = try #require(await signer.createdKeys.first)
    #expect(recorder.savedCredentials.isEmpty)
    #expect(await signer.deletedKeyIds == [key.id])
  }

  @Test
  func dismissDuringASuccessfulSaveKeepsTheKey() async throws {
    let gate = Gate()
    let viewModel = makeViewModel(onSave: { _ in await gate.pass() }, onDismiss: gate.open)
    await awaitingPin(viewModel)

    async let issuing: Void = viewModel.enterPin("123456")
    await gate.reached()
    await viewModel.dismiss()
    await issuing

    let signer = try #require(recorder.signers.first)
    #expect(recorder.savedCredentials.count == 1)
    #expect(await signer.deletedKeyIds.isEmpty)
  }

  @Test
  func dismissDuringAFailedSaveDeletesTheKey() async throws {
    let gate = Gate()
    let viewModel = makeViewModel(
      onSave: { _ in
        await gate.pass()
        throw FakeError.intentional
      },
      onDismiss: gate.open,
    )
    await awaitingPin(viewModel)

    async let issuing: Void = viewModel.enterPin("123456")
    await gate.reached()
    await viewModel.dismiss()
    await issuing

    let signer = try #require(recorder.signers.first)
    let key = try #require(await signer.createdKeys.first)
    #expect(await signer.deletedKeyIds == [key.id])
  }
}
