// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

public protocol DpopProofProviding: Sendable {
  func proof(
    endpoint: URL,
    method: HTTPMethod,
    accessToken: String?,
    nonce: String?,
  ) async throws -> String
}
