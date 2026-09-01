// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import JSONWebAlgorithms
import JSONWebKey
import Security

extension WalletJoseJWK {
  public init(secKey: SecKey) throws {
    self.init(try secKey.jwk)
  }

  init(_ jwk: JWK) {
    self.init(
      keyType: WalletJoseKeyType(rawValue: jwk.keyType.rawValue) ?? .ellipticCurve,
      curve: jwk.curve.flatMap { WalletJoseCurve(rawValue: $0.rawValue) },
      keyID: jwk.keyID,
      x: jwk.x,
      y: jwk.y,
      d: jwk.d,
    )
  }

  var joseJWK: JWK {
    JWK(
      keyType: JWK.KeyType(rawValue: keyType.rawValue) ?? .ellipticCurve,
      keyID: keyID,
      curve: curve.flatMap { JWK.CryptographicCurve(rawValue: $0.rawValue) },
      x: x,
      y: y,
      d: d,
    )
  }
}
