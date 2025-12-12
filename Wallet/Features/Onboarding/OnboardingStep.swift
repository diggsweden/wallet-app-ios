import Foundation

enum OnboardingStep: CaseIterable {
  case intro, terms, phoneNumber, verifyPhone, email, verifyEmail, pin, verifyPin, wua, pid, done

  func next() -> OnboardingStep {
    return switch self {
      case .intro: .terms
      case .terms: .phoneNumber
      case .phoneNumber: .verifyPhone
      case .verifyPhone: .email
      case .email: .verifyEmail
      case .verifyEmail: .pin
      case .pin: .verifyPin
      case .verifyPin: .wua
      case .wua: .pid
      case .pid: .done
      case .done: .done
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
