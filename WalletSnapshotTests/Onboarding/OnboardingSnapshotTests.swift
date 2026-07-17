// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import SwiftAccessMechanism
import Testing
import WalletGatewayInterface

@testable import User
@testable import WalletDemo

@MainActor
@Suite("Onboarding snapshots", .snapshots(record: .missing))
struct OnboardingSnapshotTests {
  @Test("Onboarding step", arguments: [OnboardingStep.intro, .pin, .verifyPin, .pid])
  func onboardingStep(_ step: OnboardingStep) {
    assertThemedDeviceSnapshots(
      of: onboardingRootView(step: step).withToast,
      testName: String(describing: step)
    )
  }

  @Test("PID")
  func pid() {
    assertThemedSnapshots(
      of: PidSetupView { _ in }.withToast,
      width: 360
    )
  }

  @Test func walletSetupWorking() {
    assertThemedDeviceSnapshots(of: WalletSetupContent(state: .working(.createAccount)))
  }

  @Test func walletSetupFailed() {
    assertThemedDeviceSnapshots(
      of: WalletSetupContent(state: .failed(at: .createAccount, error: CancellationError()))
    )
  }

  @Test func walletSetupComplete() {
    assertThemedDeviceSnapshots(of: WalletSetupContent(state: .complete))
  }
}

private extension OnboardingSnapshotTests {
  func onboardingRootView(step: OnboardingStep) -> OnboardingRootView {
    OnboardingRootView(
      gatewayApiClient: SnapshotGateway(),
      userSnapshot: UserSnapshot(
        accountId: nil,
        credentials: [],
        pid: nil,
        hsmServerParameters: nil
      ),
      initialStep: step,
      actions: OnboardingActions(
        signIn: { _ in },
        savePidCredential: { _ in },
        resetSession: {},
        saveHsmServerParameters: { _ in }
      )
    )
  }
}

private struct SnapshotGateway: GatewayApi, HSMTransport {
  func createAccount(publicKey: PublicKeyComponents) throws -> String { "" }
  func addAccountWalletKey(key: PublicKeyComponents) throws {}
  func getWalletUnitAttestation(nonce: String?) throws -> String { "" }

  func registerState(
    publicKey: JwkKey,
    overwrite: Bool,
    ttl: String?
  ) throws -> RegisterStateResponse {
    RegisterStateResponse(devAuthorizationCode: nil)
  }

  func perform(_ request: HSMRequest, operation: HSMOperation) throws -> Data { Data() }
}
