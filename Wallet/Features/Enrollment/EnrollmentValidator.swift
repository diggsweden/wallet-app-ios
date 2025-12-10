//import Foundation
//
//struct EnrollmentValidator {
//  static func validate(
//    step: EnrollmentStep,
//    context: EnrollmentContext
//  ) throws {
//    switch step {
//      case .pin:
//        try validatePin(context.pin)
//      case .verifyPin:
//        try validatePinMatch(originalPin: context.pin, verifyPin: context.verifyPin)
//      default:
//        break
//    }
//  }
//
//  private static func validatePin(_ pin: String) throws {
//    guard !pin.isEmpty else {
//      throw EnrollmentError.emptyPin
//    }
//
//    guard isSixDigitNumeric(pin) else {
//      throw EnrollmentError.invalidPinDigits
//    }
//  }
//
//  private static func validatePinMatch(
//    originalPin: String,
//    verifyPin: String
//  ) throws {
//    try validatePin(verifyPin)
//
//    guard originalPin == verifyPin else {
//      throw EnrollmentError.pinMismatch
//    }
//  }
//
//  private static func isSixDigitNumeric(_ string: String) -> Bool {
//    guard string.count == 6 else {
//      return false
//    }
//
//    return string.allSatisfy(\.isNumber)
//  }
//}
