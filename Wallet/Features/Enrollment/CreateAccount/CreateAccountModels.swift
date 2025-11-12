import Foundation

struct CreateAccountFormData {
  var email: String = ""
  var verifyEmail: String = ""
  var phoneNumber: String? = nil
  var pin: String = ""
}

extension CreateAccountFormData {
  private enum ValidationError: String {
    case emailEmpty = "Tom e-post"
    case emailInvalid = "Ogiltig e-postadress"
    case emailsDoNotMatch = "E-post matchar inte"
    case phoneInvalid = "Ogiltigt telefonnummer"
    case pinEmpty = "Tomt personnummer"
    case pinInvalid = "Ogiltigt personnummer"
  }

  var emailError: String? {
    if email.isEmpty {
      return ValidationError.emailEmpty.rawValue
    }

    guard Validators.isValidEmail(email) else {
      return ValidationError.emailInvalid.rawValue
    }

    return nil
  }

  var verifyEmailError: String? {
    if verifyEmail.isEmpty {
      return ValidationError.emailEmpty.rawValue
    }

    guard verifyEmail == email else {
      return ValidationError.emailsDoNotMatch.rawValue
    }

    return nil
  }

  var phoneError: String? {
    guard let phoneNumber, !phoneNumber.isEmpty else {
      return nil
    }

    guard Validators.isValidPhone(phoneNumber) else {
      return ValidationError.phoneInvalid.rawValue
    }

    return nil
  }

  var pinError: String? {
    if pin.isEmpty {
      return ValidationError.pinEmpty.rawValue
    }

    guard Validators.isValidPIN(pin) else {
      return ValidationError.pinInvalid.rawValue
    }

    return nil
  }

  var isValid: Bool {
    [emailError, verifyEmailError, phoneError, pinError].allSatisfy { $0 == nil }
  }
}

fileprivate enum Validators {
  static func isValidEmail(_ s: String) -> Bool {
    let emailRegex = /(?i)^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/
    return s.wholeMatch(of: emailRegex) != nil
  }

  static func isValidPhone(_ s: String) -> Bool {
    let allowed = CharacterSet(charactersIn: "+- 0123456789")
    return s.unicodeScalars.allSatisfy { allowed.contains($0) }
  }

  static func isValidPIN(_ pin: String) -> Bool {
    let pinRegex = /^(?:\d{2})?\d{2}(?:0[1-9]|1[0-2])(?:0[1-9]|[12]\d|3[01])[+\-]?\d{4}$/
    return pin.wholeMatch(of: pinRegex) != nil
  }
}
