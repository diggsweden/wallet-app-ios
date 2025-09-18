import Foundation

struct EnrollmentContext {
  var email: String = ""
  var verifyEmail: String = ""
  var phoneNumber: String? = nil
  var pin: String = ""
  var verifyPin: String = ""
}

extension EnrollmentContext {
  mutating func apply(_ data: ContactInfoData) {
    email = data.email
    verifyEmail = data.verifyEmail
    phoneNumber = data.phoneNumber
  }

  var userData: ContactInfoData {
    ContactInfoData(
      email: email,
      verifyEmail: verifyEmail,
      phoneNumber: phoneNumber
    )
  }
}

struct EnrollmentFlow {
  var step: EnrollmentStep = .intro

  mutating func advance(with context: EnrollmentContext) throws {
    try EnrollmentValidator.validate(step: step, context: context)
    step = step.next()
  }

  mutating func reset() {
    step = .intro
  }
}

enum EnrollmentStep {
  case intro, contactInfo, pin, verifyPin, done

  func next() -> EnrollmentStep {
    switch self {
      case .intro: return .contactInfo
      case .contactInfo: return .pin
      case .pin: return .verifyPin
      case .verifyPin: return .done
      case .done: return .done
    }
  }
}
