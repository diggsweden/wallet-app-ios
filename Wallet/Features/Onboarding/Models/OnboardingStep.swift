// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

enum OnboardingStep: CaseIterable {
  case intro
  case pin
  case verifyPin
  case walletSetup
  case pid
  case issueCredential

  func next() -> Self {
    switch self {
      case .intro: .pin
      case .pin: .verifyPin
      case .verifyPin: .walletSetup
      case .walletSetup: .pid
      case .pid: .issueCredential
      case .issueCredential: .issueCredential
    }
  }

  func previous() -> Self? {
    switch self {
      case .verifyPin: .pin
      case .issueCredential: .pid
      default: nil
    }
  }
}
