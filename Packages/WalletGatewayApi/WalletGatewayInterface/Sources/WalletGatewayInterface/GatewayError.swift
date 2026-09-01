// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

public enum GatewayError: LocalizedError {
  case invalidResponse
  case undecodableResponseBody
  case missingKeyIdentifier
  case asyncOperationFailed(message: String)
  case asyncOperationTimeout
  case problem(ProblemDetails)
  case unauthorized
  case notFound

  public var errorDescription: String? {
    switch self {
      case .invalidResponse:
        "Servern returnerade ett oväntat svar."

      case .undecodableResponseBody:
        "Något gick fel. Försök igen senare."

      case .missingKeyIdentifier:
        "Nyckelidentifierare saknas."

      case .asyncOperationFailed(let message):
        "HSM-operationen misslyckades: \(message)"

      case .asyncOperationTimeout:
        "Tidsgränsen för HSM-operationen överskreds."

      case .problem(let details):
        details.title ?? details.detail ?? "Servern returnerade ett fel (\(details.status))."

      case .unauthorized:
        "Sessionen är ogiltig eller har gått ut."

      case .notFound:
        "Resursen kunde inte hittas."
    }
  }
}
