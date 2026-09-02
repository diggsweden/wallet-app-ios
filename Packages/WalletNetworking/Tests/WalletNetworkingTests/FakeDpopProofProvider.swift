// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

@testable import WalletNetworking

struct FakeDpopProofProvider: DpopProofProviding {
  // swiftlint:disable async_without_await
  func proof(
    endpoint: URL,
    method: HTTPMethod,
    accessToken: String?,
    nonce: String?,
  ) async throws -> String {
    "\(method.rawValue) \(endpoint.absoluteString) nonce=\(nonce ?? "-")"
  }
  // swiftlint:enable async_without_await
}
