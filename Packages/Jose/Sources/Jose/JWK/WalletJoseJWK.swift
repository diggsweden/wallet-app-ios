// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

public enum WalletJoseKeyType: String, Codable, Sendable {
  case ellipticCurve = "EC"
  case rsa = "RSA"
  case octetSequence = "oct"
  case octetKeyPair = "OKP"
}

public enum WalletJoseCurve: String, Codable, Sendable {
  case p256 = "P-256"
  case p384 = "P-384"
  case p521 = "P-521"
  case x25519 = "X25519"
  case ed25519 = "Ed25519"
  case x448 = "X448"
  case ed448 = "Ed448"
  case secp256k1
}

public struct WalletJoseJWK: Codable, Sendable {
  public var keyType: WalletJoseKeyType
  public var curve: WalletJoseCurve?
  public var keyID: String?
  public var algorithm: String?
  public var x: Data?
  public var y: Data?
  public var d: Data?

  public init(
    keyType: WalletJoseKeyType,
    curve: WalletJoseCurve? = nil,
    keyID: String? = nil,
    algorithm: String? = nil,
    x: Data? = nil,
    y: Data? = nil,
    d: Data? = nil,
  ) {
    self.keyType = keyType
    self.curve = curve
    self.keyID = keyID
    self.algorithm = algorithm
    self.x = x
    self.y = y
    self.d = d
  }
}
