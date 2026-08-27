// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

public struct HsmServerParameters: Equatable, Sendable {
  public let serverJwsPublicKey: Jwk
  public let opaqueContext: Data
  public let opaqueServerIdentifier: Data

  public init(serverJwsPublicKey: Jwk, opaqueContext: Data, opaqueServerIdentifier: Data) {
    self.serverJwsPublicKey = serverJwsPublicKey
    self.opaqueContext = opaqueContext
    self.opaqueServerIdentifier = opaqueServerIdentifier
  }

  public struct Jwk: Equatable, Sendable {
    public let kty: String
    public let crv: String
    public let x: String
    public let y: String
    public let kid: String?

    public init(kty: String, crv: String, x: String, y: String, kid: String?) {
      self.kty = kty
      self.crv = crv
      self.x = x
      self.y = y
      self.kid = kid
    }
  }
}
