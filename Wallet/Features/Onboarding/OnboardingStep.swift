// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

enum OnboardingStep: CaseIterable {
  case intro, terms, login, phoneNumber, verifyPhone, email, verifyEmail, pin, verifyPin, pid,
    issueCredential

  func next() -> OnboardingStep {
    return switch self {
      case .intro: .terms
      case .terms: .login
      case .login: .phoneNumber
      case .phoneNumber: .verifyPhone
      case .verifyPhone: .email
      case .email: .verifyEmail
      case .verifyEmail: .pin
      case .pin: .verifyPin
      case .verifyPin: .pid
      case .pid: .issueCredential
      case .issueCredential: .issueCredential
    }
  }

  func previous() -> OnboardingStep? {
    return switch self {
      case .verifyPhone: .phoneNumber
      case .verifyEmail: .email
      case .verifyPin: .pin
      case .issueCredential: .pid
      default: nil
    }
  }
}
