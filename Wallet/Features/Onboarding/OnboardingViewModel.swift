// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import SwiftAccessMechanism
import SwiftUI

@MainActor
@Observable
final class OnboardingViewModel {
  enum StepTransition {
    case start, forward, back
  }

  private let savePidCredentialAction: (SavedCredential) async throws -> Void
  private let signInAction: (String) async throws -> Void
  private let resetSessionAction: () async throws -> Void
  private let saveHsmServerParametersAction: (ServerParameters) async throws -> Void

  private(set) var context = OnboardingContext()
  private(set) var step: OnboardingStep = .intro
  private(set) var stepTransition: StepTransition = .start

  private var hadResetError: Bool = false

  init(
    savePidCredential: @escaping (SavedCredential) async throws -> Void,
    signIn: @escaping (String) async throws -> Void,
    onReset: @escaping () async throws -> Void,
    saveHsmServerParameters: @escaping (ServerParameters) async throws -> Void
  ) {
    self.savePidCredentialAction = savePidCredential
    self.signInAction = signIn
    self.resetSessionAction = onReset
    self.saveHsmServerParametersAction = saveHsmServerParameters
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
    try await signInAction(accountId)
  }

  func savePidCredential(_ credential: SavedCredential) async throws {
    try await savePidCredentialAction(credential)
  }

  func saveHsmServerParameters(_ parameters: ServerParameters) async throws {
    try await saveHsmServerParametersAction(parameters)
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
    hadResetError = false

    do {
      try await resetSessionAction()
      context = OnboardingContext()
      stepTransition = .start
      step = .intro
    } catch {
      hadResetError = true
    }
  }
}
