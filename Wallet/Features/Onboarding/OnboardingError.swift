import Foundation

enum OnboardingError: LocalizedError {
  case invalidPinDigits
  case pinMismatch
  case authFailure

  var errorDescription: String? {
    return switch self {
      case .invalidPinDigits:
        "PIN-koden måste bestå av 6 siffror"
      case .pinMismatch:
        "PIN-koderna matchar inte"
      case .authFailure:
        "Kunde inte logga in"
    }
  }
}
