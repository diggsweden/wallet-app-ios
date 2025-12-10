import Foundation

enum EnrollmentError: LocalizedError {
  case invalidPinDigits
  case pinMismatch

  var errorDescription: String? {
    switch self {
      case .invalidPinDigits:
        return "PIN-koden måste bestå av 6 siffror"
      case .pinMismatch:
        return "PIN-koderna matchar inte"
    }
  }
}
