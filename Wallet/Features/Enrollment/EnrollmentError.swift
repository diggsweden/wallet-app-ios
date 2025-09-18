import Foundation

enum EnrollmentError: LocalizedError {
  case emptyEmail
  case invalidEmail
  case emailMismatch
  case emptyPin
  case invalidPinDigits
  case pinMismatch

  var errorDescription: String? {
    switch self {
      case .emptyEmail:
        return "E-post får inte vara tom"
      case .invalidEmail:
        return "Ogiltig e-postadress"
      case .emailMismatch:
        return "E-postadresserna matchar inte"
      case .emptyPin:
        return "Ange en 6-siffrig PIN-kod"
      case .invalidPinDigits:
        return "PIN-koden måste bestå av 6 siffror"
      case .pinMismatch:
        return "PIN-koderna matchar inte"
    }
  }
}
