import Foundation

enum OnboardingStep: CaseIterable {
  case intro, login, terms, phoneNumber, verifyPhone, email, verifyEmail, pin, verifyPin, pid

  func next() -> OnboardingStep {
    return switch self {
      case .intro: .login
      case .login: .terms
      case .terms: .phoneNumber
      case .phoneNumber: .verifyPhone
      case .verifyPhone: .email
      case .email: .verifyEmail
      case .verifyEmail: .pin
      case .pin: .verifyPin
      case .verifyPin: .pid
      case .pid: .pid
    }
  }

  func previous() -> OnboardingStep? {
    return switch self {
      case .verifyPhone: .phoneNumber
      case .verifyEmail: .email
      case .verifyPin: .pin
      default: nil
    }
  }
}
