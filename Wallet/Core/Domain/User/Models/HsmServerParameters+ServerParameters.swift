// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import SwiftAccessMechanism
import User

extension HsmServerParameters {
  /// Builds the persistent DTO from the library's `ServerParameters`.
  init(_ parameters: ServerParameters) {
    self.init(
      serverJwsPublicKey: Jwk(
        kty: parameters.serverJwsPublicKey.kty,
        crv: parameters.serverJwsPublicKey.crv,
        x: parameters.serverJwsPublicKey.x,
        y: parameters.serverJwsPublicKey.y,
        kid: parameters.serverJwsPublicKey.kid
      ),
      opaqueContext: parameters.opaqueContext,
      opaqueServerIdentifier: parameters.opaqueServerIdentifier
    )
  }

  /// Reconstructs `ServerParameters`.
  ///
  /// `ServerParameters` has no public memberwise initializer, so it is rebuilt through its
  /// `Codable` conformance — the sanctioned persistence/restore path documented by the library.
  func toServerParameters() throws -> ServerParameters {
    let encoded = try JSONEncoder().encode(ServerParametersRepresentation(self))
    return try JSONDecoder().decode(ServerParameters.self, from: encoded)
  }
}

/// Encodes to the exact JSON shape that `ServerParameters` decodes from.
private struct ServerParametersRepresentation: Encodable {
  let serverJwsPublicKey: JwkKey
  let opaqueContext: Data
  let opaqueServerIdentifier: Data

  init(_ parameters: HsmServerParameters) {
    self.serverJwsPublicKey = JwkKey(
      kty: parameters.serverJwsPublicKey.kty,
      crv: parameters.serverJwsPublicKey.crv,
      x: parameters.serverJwsPublicKey.x,
      y: parameters.serverJwsPublicKey.y,
      kid: parameters.serverJwsPublicKey.kid
    )
    self.opaqueContext = parameters.opaqueContext
    self.opaqueServerIdentifier = parameters.opaqueServerIdentifier
  }
}
