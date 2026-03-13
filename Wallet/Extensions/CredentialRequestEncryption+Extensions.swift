// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import JSONWebAlgorithms
import JSONWebKey
import OpenID4VCI

extension CredentialRequestEncryption? {
  func toCryptoSpec() -> CryptoSpec? {
    guard case let .required(jwks, methods, _) = self,
      let joseJwk = jwks.first,
      let method = methods.first,
      let enc = ContentEncryptionAlgorithm(rawValue: method.name),
      let jwkData = joseJwk.jsonData(),
      let jwk = try? JSONDecoder().decode(JWK.self, from: jwkData)
    else {
      return nil
    }

    return CryptoSpec(key: jwk, enc: enc)
  }
}
