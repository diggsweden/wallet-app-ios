// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Jose
import OpenID4VCI

// swift-format-ignore: AvoidRetroactiveConformances
extension DpopProofBuilder: @retroactive DPoPConstructorType {
  public func jwt(endpoint: URL, accessToken: String?, nonce: Nonce?) async throws -> String {
    try await proof(
      endpoint: endpoint,
      method: .post,
      accessToken: accessToken,
      nonce: nonce?.value,
    )
  }
}
