import SwiftUI

@MainActor
@Observable
final class EnrollmentViewModel {
  private let setKeyAttestation: (String) async -> Void
  private let signIn: (String) async -> Void
  private let onReset: () async -> Void

  private(set) var step: EnrollmentStep = .intro
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

  private var allSteps: [EnrollmentStep] {
    return EnrollmentStep.allCases.filter { $0 != .intro }
  }

  func setPin(_ pin: String) throws {
    guard pin.count == 6 else {
      throw EnrollmentError.invalidPinDigits
    }

    self.pin = pin
    next()
  }

  func setPhoneNumber(_ phoneNumber: String) {
    self.phoneNumber = phoneNumber
    next()
  }

  func skipPhoneNumber() {
    step = .email
  }

  func signIn(accountId: String, email: String) async {
    await signIn(accountId)
    self.email = email
    next()
  }

  func addKeyAttestation(_ keyAttestation: String) async {
    await setKeyAttestation(keyAttestation)
    next()
  }

  func confirmPin(_ pin: String) throws {
    guard self.pin == pin else {
      step = .pin
      throw EnrollmentError.pinMismatch
    }
    next()
  }

  func next() {
    step = step.next()
  }

  func back() {
    if let previous = step.previous() {
      step = previous
    }
  }
  
  func canGoBack() -> Bool {
    step.previous() != nil
  }

  func reset() async {
    await onReset()
    step = .intro
  }
}
