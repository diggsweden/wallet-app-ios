// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

@MainActor
@Observable
final class WalletSetupViewModel {
  private let service: any WalletSetupService
  private let pin: String
  private(set) var state: WalletSetupState = .idle
  private let onComplete: () -> Void

  init(
    service: any WalletSetupService,
    pin: String,
    onComplete: @escaping () -> Void,
  ) {
    self.service = service
    self.pin = pin
    self.onComplete = onComplete
  }

  func setup() async {
    await resume(from: .createAccount)
  }

  func retry() async {
    guard case .failed(let step, _) = state else {
      return
    }
    await resume(from: step)
  }

  private func resume(from startStep: WalletSetupStep) async {
    var current: WalletSetupStep? = startStep
    while let step = current {
      state = .working(step)
      do {
        current = try await perform(step)
      } catch {
        state = .failed(at: step, CaughtError(error))
        return
      }
    }
    state = .complete
    onComplete()
  }

  private func perform(_ step: WalletSetupStep) async throws -> WalletSetupStep? {
    switch step {
      case .createAccount:
        try await service.createAccount()
        return .setInitialBackendGeneration

      case .setInitialBackendGeneration:
        try await service.setInitialBackendGeneration()
        return .initHSMState

      case .initHSMState:
        try await service.initHSMState()
        return .registerPin

      case .registerPin:
        _ = try await service.registerPin(pin: pin)
        return nil
    }
  }
}
