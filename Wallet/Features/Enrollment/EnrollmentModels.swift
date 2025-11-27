import Foundation

struct EnrollmentContext {
  var email: String = ""
  var verifyEmail: String = ""
  var phoneNumber: String? = nil
  var pin: String = ""
  var verifyPin: String = ""
}

struct EnrollmentFlow {
  var step: EnrollmentStep = .intro

  var currentStepNumber: Int? {
    guard let caseIndex = EnrollmentStep.allCases.firstIndex(of: step) else {
      return nil
    }
    return caseIndex + 1
  }

  var totalSteps: Int {
    return EnrollmentStep.allCases.count
  }

  mutating func advance(with context: EnrollmentContext) throws {
    do {
      try EnrollmentValidator.validate(step: step, context: context)
    } catch let error as EnrollmentError {
      if case .pinMismatch = error {
        step = .pin
      }
      throw error
    }
    step = step.next()
  }

  mutating func reset() {
    step = .intro
  }
}

enum EnrollmentStep: CaseIterable {
  case intro, contactInfo, pin, verifyPin, wua, pid, done

  func next() -> EnrollmentStep {
    switch self {
      case .intro: return .contactInfo
      case .contactInfo: return .pin
      case .pin: return .verifyPin
      case .verifyPin: return .wua
      case .wua: return .pid
      case .pid: return .done
      case .done: return .done
    }
  }
}
