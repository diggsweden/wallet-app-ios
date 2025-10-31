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
        try validateEmailPair(email: context.email, verifyEmail: context.verifyEmail)
      case .pin:
        try validatePin(context.pin)
      case .verifyPin:
        try validatePinMatch(originalPin: context.pin, verifyPin: context.verifyPin)
      default:
        break
    }
  }

  private static func validateEmailPair(
    email: String,
    verifyEmail: String
  ) throws {
    guard !email.isEmpty else {
      throw EnrollmentError.emptyEmail
    }

    guard isValidEmail(email) else {
      throw EnrollmentError.invalidEmail
    }

    guard email == verifyEmail else {
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
    originalPin: String,
    verifyPin: String
  ) throws {
    try validatePin(verifyPin)

    guard originalPin == verifyPin else {
      throw EnrollmentError.pinMismatch
    }
  }

  private static func isValidEmail(_ email: String) -> Bool {
    let range = NSRange(email.startIndex ..< email.endIndex, in: email)
    return emailRegex.firstMatch(in: email, options: [], range: range) != nil
  }

  private static func isSixDigitNumeric(_ string: String) -> Bool {
    guard string.count == 6 else {
      return false
    }

    return string.allSatisfy(\.isNumber)
  }
}
