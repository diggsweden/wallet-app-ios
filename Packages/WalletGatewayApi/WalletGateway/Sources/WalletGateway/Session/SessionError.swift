// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

public enum SessionError: LocalizedError {
  case noAccountId
  case noKeyId
  case problem(ProblemDetails)
  case unauthorized
  case undecodableResponseBody

  public var errorDescription: String? {
    switch self {
      case .noAccountId:
        "No account ID available"

      case .noKeyId:
        "No key ID available"

      case .problem(let details):
        details.title ?? details.detail ?? "Servern returnerade ett fel (\(details.status))."

      case .unauthorized:
        "Sessionen är ogiltig eller har gått ut."

      case .undecodableResponseBody:
        "Något gick fel. Försök igen senare."
    }
  }
}
