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

  private let actions: OnboardingActions

  private(set) var context = OnboardingContext()
  private(set) var step: OnboardingStep = .intro
  private(set) var stepTransition: StepTransition = .start

  private var hadResetError: Bool = false

  init(
    step: OnboardingStep = .intro,
    actions: OnboardingActions,
  ) {
    self.step = step
    self.actions = actions
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
    try await actions.signIn(accountId)
  }

  func saveCredential(_ credential: SavedCredential) async throws {
    try await actions.saveCredential(credential)
  }

  func saveHsmServerParameters(_ parameters: ServerParameters) async throws {
    try await actions.saveHsmServerParameters(parameters)
  }

  func saveBackendGeneration(_ generation: Int) async throws {
    try await actions.saveBackendGeneration(generation)
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

  func onCompleteOnboarding() async throws {
    try await actions.onComplete()
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
      try await actions.resetSession()
      context = OnboardingContext()
      stepTransition = .start
      step = .intro
    } catch {
      hadResetError = true
    }
  }
}
