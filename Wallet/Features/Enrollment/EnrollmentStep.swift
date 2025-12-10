import Foundation

enum EnrollmentStep: CaseIterable {
  case intro, terms, phoneNumber, verifyPhone, email, verifyEmail, pin, verifyPin, wua, pid, done

  func next() -> EnrollmentStep {
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

  func previous() -> EnrollmentStep? {
    return switch self {
      case .verifyPhone: .phoneNumber
      case .verifyEmail: .email
      case .verifyPin: .pin
      default: nil
    }
  }
}
