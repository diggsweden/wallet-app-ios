// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Jose
import OpenID4VCI

extension CredentialRequestEncryption? {
  func toCryptoSpec() -> CryptoSpec? {
    guard case let .required(jwks, methods, _) = self,
      let joseJwk = jwks.first,
      let method = methods.first,
      let enc = WalletJoseContentEncryptionAlgorithm(rawValue: method.name),
      let jwkData = joseJwk.jsonData(),
      let jwk = try? JSONDecoder().decode(WalletJoseJWK.self, from: jwkData)
    else {
      return nil
    }

    return CryptoSpec(key: jwk, enc: enc)
  }
}
