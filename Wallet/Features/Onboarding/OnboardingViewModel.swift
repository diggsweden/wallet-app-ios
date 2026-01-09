import SwiftUI

@MainActor
@Observable
final class OnboardingViewModel {
  enum StepTransition {
    case start, forward, back
  }

  private let setKeyAttestation: (String) async -> Void
  private let signIn: (String) async -> Void
  private let onReset: () async -> Void

  private(set) var step: OnboardingStep = .intro
  private(set) var stepTransition: StepTransition = .start
  private(set) var pin = ""
  private(set) var phoneNumber: String?
  private(set) var email = ""

  init(
    setKeyAttestation: @escaping (String) async -> Void,
    signIn: @escaping (String) async -> Void,
    onReset: @escaping () async -> Void
  ) {
    self.setKeyAttestation = setKeyAttestation
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

    self.pin = pin
  }

  func setPhoneNumber(_ phoneNumber: String) {
    self.phoneNumber = phoneNumber
  }

  func skipPhoneNumber() {
    step = .email
  }

  func signIn(accountId: String, email: String) async {
    await signIn(accountId)
    self.email = email
  }

  func addKeyAttestation(_ keyAttestation: String) async {
    await setKeyAttestation(keyAttestation)
  }

  func confirmPin(_ pin: String) throws {
    guard self.pin == pin else {
      stepTransition = .back
      step = .pin
      throw OnboardingError.pinMismatch
    }
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
    stepTransition = .start
    step = .intro
  }
}
