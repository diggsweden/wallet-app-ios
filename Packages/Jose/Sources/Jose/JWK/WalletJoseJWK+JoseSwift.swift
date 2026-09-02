// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CryptoKit
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

extension WalletJoseJWK {
  public init(from decoder: any Decoder) throws {
    self.init(try JWK(from: decoder))
  }

  public func encode(to encoder: any Encoder) throws {
    try joseJWK.encode(to: encoder)
  }
}

extension WalletJoseJWK {
  public init(_ key: P256.Signing.PublicKey) {
    self.init(key.jwkRepresentation)
  }

  public init(_ key: P256.Signing.PrivateKey) {
    self.init(key.jwkRepresentation)
  }

  public init(_ key: P256.KeyAgreement.PublicKey) {
    self.init(key.jwkRepresentation)
  }

  public init(_ key: P256.KeyAgreement.PrivateKey) {
    self.init(key.jwkRepresentation)
  }

  public func thumbprint() throws -> String {
    try joseJWK.thumbprint()
  }
}
