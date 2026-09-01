// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import OpenID4VCI

extension DpopProofBuilder: DPoPConstructorType {
  func jwt(endpoint: URL, accessToken: String?, nonce: Nonce?) async throws -> String {
    try await proof(
      endpoint: endpoint,
      method: .post,
      accessToken: accessToken,
      nonce: nonce?.value,
    )
  }
}
