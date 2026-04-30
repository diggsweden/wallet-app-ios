// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

public struct PublicKeyComponents: Sendable {
  public let kty: String
  public let kid: String
  public let crv: String
  public let x: String
  public let y: String

  public init(kty: String, kid: String, crv: String, x: String, y: String) {
    self.kty = kty
    self.kid = kid
    self.crv = crv
    self.x = x
    self.y = y
  }
}
