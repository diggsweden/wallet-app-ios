// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

enum SessionError: LocalizedError {
  case noAccountID, failedChallenge, noKeyId

  var errorDescription: String? {
    return switch self {
      case .noAccountID:
        "No account ID available"
      case .failedChallenge:
        "Failed to complete challenge"
      case .noKeyId:
        "No key ID available"
    }
  }
}
