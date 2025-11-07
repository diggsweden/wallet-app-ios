import Foundation

struct ContactInfoData {
  var email: String = ""
  var verifyEmail: String = ""
  var phoneNumber: String? = nil
  var pin: String = ""
}

enum ContactError: String {
  case emailEmpty = "Tom epost"
  case emailInvalid = "Ogiltig epostadress"
  case emailsDoNotMatch = "Epost matchar inte"
  case phoneInvalid = "Ogiltigt telefonnummer"
  case pinEmpty = "Tomt personnummer"
  case pinInvalid = "Ogiltigt personnummer"
}

extension ContactInfoData {
  var emailError: String? {
    if email.isEmpty { return ContactError.emailEmpty.rawValue }
    if !Validators.isValidEmail(email) { return ContactError.emailInvalid.rawValue }
    return nil
  }

  var verifyEmailError: String? {
    if verifyEmail.isEmpty { return ContactError.emailEmpty.rawValue }
    if verifyEmail != email { return ContactError.emailsDoNotMatch.rawValue }
    return nil
  }

  var phoneError: String? {
    guard let phoneNumber, !phoneNumber.isEmpty else { return nil }
    return Validators.isValidPhone(phoneNumber) ? nil : ContactError.phoneInvalid.rawValue
  }

  var pinError: String? {
    if pin.isEmpty { return ContactError.pinEmpty.rawValue }
    return Validators.isValidPIN(pin) ? nil : ContactError.pinInvalid.rawValue
  }

  var isValid: Bool {
    [emailError, verifyEmailError, phoneError, pinError].allSatisfy { $0 == nil }
  }
}

fileprivate enum Validators {
  static func isValidEmail(_ s: String) -> Bool {
    let re = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/
    return s.wholeMatch(of: re) != nil
  }

  static func isValidPhone(_ s: String) -> Bool {
    let allowed = CharacterSet(charactersIn: "+-() 0123456789")
    return s.unicodeScalars.allSatisfy { allowed.contains($0) }
  }

  static func isValidPIN(_ pin: String) -> Bool {
    let pinRegex = /^(?:\d{2})?\d{2}(?:0[1-9]|1[0-2])(?:0[1-9]|[12]\d|3[01])[+\-]?\d{4}$/
    return pin.wholeMatch(of: pinRegex) != nil
  }
}
