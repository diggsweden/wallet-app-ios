// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import JSONWebKey

struct GatewayApiMock: GatewayApi {
  func createAccount(
    personalIdentityNumber: String,
    emailAddress: String,
    telephoneNumber: String?,
    jwk: JWK,
  ) async throws -> String {
    return ""
  }

  func getWalletUnitAttestation(nonce: String) async throws -> String {
    return ""
  }
}
