import SwiftUI

@MainActor
@Observable
final class OnboardingViewModel {
  enum StepTransition {
    case start, forward, back
  }

  private let setPidCredential: (Credential) async -> Void
  private let signIn: (String) async -> Void
  private let onReset: () async -> Void

  private(set) var context = OnboardingContext()
  private(set) var step: OnboardingStep = .intro
  private(set) var stepTransition: StepTransition = .start

  init(
    setPidCredential: @escaping (Credential) async -> Void,
    signIn: @escaping (String) async -> Void,
    onReset: @escaping () async -> Void
  ) {
    self.setPidCredential = setPidCredential
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
    return allSteps.count
  }

  private var allSteps: [OnboardingStep] {
    return OnboardingStep.allCases.filter { $0 != .intro }
  }

  func setPin(_ pin: String) throws {
    guard pin.count == 6 else {
      throw OnboardingError.invalidPinDigits
    }

    context.pin = pin
  }

  func setPhoneNumber(_ phoneNumber: String) {
    context.phoneNumber = phoneNumber
  }

  func skipPhoneNumber() {
    step = .email
  }

  func signIn(accountId: String, email: String) async {
    await signIn(accountId)
    context.email = email
  }

  func setCredentialOfferUri(_ credential: Credential) async {
    await setPidCredential(credential)
  }

  func confirmPin(_ pin: String) throws {
    guard context.pin == pin else {
      stepTransition = .back
      step = .pin
      throw OnboardingError.pinMismatch
    }
  }

  func setOidcSessionId(_ oidcSessionId: String) {
    context.oidcSessionId = oidcSessionId
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
    await onReset()
    context = OnboardingContext()
    stepTransition = .start
    step = .intro
  }
}
