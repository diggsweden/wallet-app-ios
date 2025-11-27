import Foundation

struct CreateAccountFormData {
  var email: String = ""
  var verifyEmail: String = ""
  var phoneNumber: String? = nil
  var acceptedTerms: Bool = false
}

extension CreateAccountFormData {
  private enum ValidationError: String {
    case emailEmpty = "Tom e-post"
    case emailInvalid = "Ogiltig e-postadress"
    case emailsDoNotMatch = "E-post matchar inte"
    case phoneInvalid = "Ogiltigt telefonnummer"
    case notAcceptedTerms = "Samtycke krävs för att du ska kunna använda plånboken"
  }
  var emailMatchError: String? {
    guard Validators.isValidEmail(email) && Validators.isValidEmail(verifyEmail) else {
      return nil
    }
    
    return email == verifyEmail ? nil : ValidationError.emailsDoNotMatch.rawValue
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

    guard Validators.isValidEmail(verifyEmail) else {
      return ValidationError.emailInvalid.rawValue
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

  var termsError: String? {
    return acceptedTerms ? nil : ValidationError.notAcceptedTerms.rawValue
  }

  var isValid: Bool {
    [emailError, verifyEmailError, phoneError, termsError].allSatisfy { $0 == nil }
  }
}

fileprivate enum Validators {
  static func isValidEmail(_ input: String) -> Bool {
    let emailRegex = /(?i)^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/
    return input.wholeMatch(of: emailRegex) != nil
  }

  static func isValidPhone(_ input: String) -> Bool {
    input.wholeMatch(of: /^\d{10}$/) != nil
  }
}
