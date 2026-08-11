// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

enum RequestAuthorization {
  case bearer(String)
  case dpop(accessToken: String, proofBuilder: any DpopProofProviding)

  func headers(
    endpoint: URL,
    method: HTTPMethod,
    dpopNonce: String?,
  ) async throws -> [String: String] {
    switch self {
      case .bearer(let accessToken):
        return ["Authorization": "Bearer \(accessToken)"]

      case .dpop(let accessToken, let proofBuilder):
        let proof = try await proofBuilder.proof(
          endpoint: endpoint,
          method: method,
          accessToken: accessToken,
          nonce: dpopNonce,
        )

        return [
          "Authorization": "DPoP \(accessToken)",
          "DPoP": proof,
        ]
    }
  }
}
