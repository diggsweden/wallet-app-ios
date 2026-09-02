// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

public enum PresentationError: LocalizedError {
  case noCredential
  case noMatchingClaims
  case noMatchingCredential
  case resolutionFailed(String)
  case unsupportedQuery
  case unsupportedResponseMode
  case keyBindingEncodingFailed

  public var errorDescription: String? {
    switch self {
      case .resolutionFailed(let detail):
        detail

      case .noCredential:
        "Hittade inga attributsintyg att verifiera mot"

      default:
        "Något gick fel vid delning av uppgifter."
    }
  }
}
