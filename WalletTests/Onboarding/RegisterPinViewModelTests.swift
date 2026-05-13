// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import SwiftAccessMechanism
import Testing

@testable import WalletDemo

// MARK: - Mock

@MainActor
final class MockWalletSetupService: WalletSetupService {
  var failAt: WalletSetupStep?

  private(set) var createAccountCallCount = 0
  private(set) var initHSMStateCallCount = 0
  private(set) var registerPinCallCount = 0
  private(set) var authenticateCallCount = 0
  private(set) var generateHSMKeyCallCount = 0
  private(set) var saveKeyCallCount = 0

  func createAccount() throws {
    createAccountCallCount += 1
    if let failAt, case .createAccount = failAt { throw MockError.intentional }
  }

  func initHSMState() throws {
    initHSMStateCallCount += 1
    if let failAt, case .initHSMState = failAt { throw MockError.intentional }
  }

  func registerPin(pin: String) throws -> StretchedPIN {
    registerPinCallCount += 1
    if let failAt, case .registerPin = failAt { throw MockError.intentional }
    return try PINStretch().stretch(input: Data(pin.utf8))
  }

  func authenticate(pin: StretchedPIN) throws {
    authenticateCallCount += 1
    if let failAt, case .authenticate = failAt { throw MockError.intentional }
  }

  func generateHSMKey() throws -> PublicKeyComponents {
    generateHSMKeyCallCount += 1
    if let failAt, case .generateHSMKey = failAt { throw MockError.intentional }
    return PublicKeyComponents(kty: "EC", kid: "mock-kid", crv: "P-256", x: "mock-x", y: "mock-y")
  }

  func saveKey(key: PublicKeyComponents) throws {
    saveKeyCallCount += 1
    if let failAt, case .saveKey = failAt { throw MockError.intentional }
  }
}

enum MockError: Error {
  case intentional
}

// MARK: - Tests

@MainActor
struct WalletSetupViewModelTests {
  @Test func completesSuccessfully() async {
    let service = MockWalletSetupService()
    let vm = WalletSetupViewModel(service: service, pin: "1234")
    await vm.setup()
    #expect(vm.state == .complete)
  }

  @Test func setsCorrectStateOnFailure() async throws {
    let service = MockWalletSetupService()
    let stretched = try PINStretch().stretch(input: Data("1234".utf8))
    service.failAt = .authenticate(stretched)
    let vm = WalletSetupViewModel(service: service, pin: "1234")
    await vm.setup()
    #expect(vm.state == .failed(at: .authenticate(stretched), error: MockError.intentional))
  }

  @Test func retryResumesFromFailedStep() async throws {
    let service = MockWalletSetupService()
    let stretched = try PINStretch().stretch(input: Data("1234".utf8))
    service.failAt = .authenticate(stretched)
    let vm = WalletSetupViewModel(service: service, pin: "1234")
    await vm.setup()

    service.failAt = nil
    await vm.retry()

    #expect(vm.state == .complete)
    #expect(service.createAccountCallCount == 1)
    #expect(service.initHSMStateCallCount == 1)
    #expect(service.registerPinCallCount == 1)
    #expect(service.authenticateCallCount == 2)
  }

  @Test func retryDoesNothingIfNotFailed() async {
    let service = MockWalletSetupService()
    let vm = WalletSetupViewModel(service: service, pin: "1234")
    await vm.setup()
    await vm.retry()
    #expect(service.createAccountCallCount == 1)
  }
}
