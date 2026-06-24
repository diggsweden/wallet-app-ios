// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import SwiftUI

@MainActor
@Observable
final class OnboardingViewModel {
  enum StepTransition {
    case start, forward, back
  }

  private let savePidCredential: (SavedCredential) async throws -> Void
  private let signIn: (String) async throws -> Void
  private let onReset: () async throws -> Void

  private(set) var context = OnboardingContext()
  private(set) var step: OnboardingStep = .intro
  private(set) var stepTransition: StepTransition = .start

  init(
    savePidCredential: @escaping (SavedCredential) async throws -> Void,
    signIn: @escaping (String) async throws -> Void,
    onReset: @escaping () async throws -> Void
  ) {
    self.savePidCredential = savePidCredential
    self.signIn = signIn
    self.onReset = onReset
  }

  var currentStepNumber: Int? {
    guard let caseIndex = allSteps.firstIndex(of: step) else {
      return nil
    }
    return caseIndex + 1
  }

  var totalSteps: Int {
    allSteps.count
  }

  private var allSteps: [OnboardingStep] {
    OnboardingStep.allCases.filter { $0 != .intro }
  }

  func setPin(_ pin: String) throws {
    guard pin.count == 6 else {
      throw OnboardingError.invalidPinDigits
    }

    context.pin = pin
  }

  func signIn(accountId: String) async throws {
    try await signIn(accountId)
  }

  func setCredentialOfferURI(_ credential: SavedCredential) async {
    // TODO: [DM] Handle Error
    try? await savePidCredential(credential)
  }

  func confirmPin(_ pin: String) throws {
    guard context.pin == pin else {
      stepTransition = .back
      step = .pin
      throw OnboardingError.pinMismatch
    }
  }

  func setCredentialOfferUri(_ credentialOfferUri: String) {
    context.credentialOfferUri = credentialOfferUri
  }

  func next(from step: OnboardingStep) {
    guard self.step == step else {
      return
    }

    stepTransition = .forward
    self.step = step.next()
  }

  func back() {
    if let previous = step.previous() {
      stepTransition = .back
      step = previous
    }
  }

  func canGoBack() -> Bool {
    step.previous() != nil
  }

  func reset() async {
    // TODO: [DM] Handle Error
    try? await onReset()
    context = OnboardingContext()
    stepTransition = .start
    step = .intro
  }
}
