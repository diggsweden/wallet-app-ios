// SPDX-FileCopyrightText: 2026 diggsweden/wallet-app-ios
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

enum OnboardingError: LocalizedError {
  case invalidPinDigits
  case pinMismatch
  case authFailure
  case pidFailure

  var errorDescription: String? {
    return switch self {
      case .invalidPinDigits:
        "PIN-koden måste bestå av 6 siffror"
      case .pinMismatch:
        "PIN-koderna matchar inte"
      case .authFailure:
        "Kunde inte logga in"
      case .pidFailure:
        "Kunde inte hämta ID-handling"
    }
  }
}
