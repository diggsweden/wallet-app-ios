import Foundation

struct EnrollmentValidator {
  private static let emailRegex: NSRegularExpression = {
    let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
    // swift-format-ignore
    return try! NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
  }()

  static func validate(
    step: EnrollmentStep,
    context: EnrollmentContext
  ) throws {
    switch step {
      case .contactInfo:
        try validateEmailPair(email: context.email, verify: context.verifyEmail)
      case .pin:
        try validatePin(context.pin)
      case .verifyPin:
        try validatePinMatch(pin: context.pin, verify: context.verifyPin)
      default:
        break
    }
  }

  private static func validateEmailPair(
    email rawEmail: String,
    verify rawVerify: String
  ) throws {
    let email = rawEmail.trimmingCharacters(in: .whitespacesAndNewlines)
    let verify = rawVerify.trimmingCharacters(in: .whitespacesAndNewlines)

    guard !email.isEmpty else {
      throw EnrollmentError.emptyEmail
    }
    guard isValidEmail(email) else {
      throw EnrollmentError.invalidEmail
    }
    guard email == verify else {
      throw EnrollmentError.emailMismatch
    }
  }

  private static func validatePin(_ pin: String) throws {
    guard !pin.isEmpty else {
      throw EnrollmentError.emptyPin
    }
    guard isSixDigitNumeric(pin) else {
      throw EnrollmentError.invalidPinDigits
    }
  }

  private static func validatePinMatch(
    pin: String,
    verify: String
  ) throws {
    guard !verify.isEmpty else {
      throw EnrollmentError.emptyPin
    }
    guard isSixDigitNumeric(pin) else {
      throw EnrollmentError.invalidPinDigits
    }
    guard pin == verify else {
      throw EnrollmentError.pinMismatch
    }
  }

  private static func isValidEmail(_ email: String) -> Bool {
    let range = NSRange(email.startIndex ..< email.endIndex, in: email)
    return emailRegex.firstMatch(in: email, options: [], range: range) != nil
  }

  private static func isSixDigitNumeric(_ string: String) -> Bool {
    guard string.count == 6 else { return false }
    return string.allSatisfy({ $0.isNumber })
  }
}
