// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import JSONWebKey

enum JwkMappingError: Error {
  case missingCurve
  case missingX
  case missingY
}

struct JwkDtoMapper {
  static func makeDto(from jwk: JWK) throws -> Components.Schemas.JwkDto {
    guard let curve = jwk.curve?.rawValue else {
      throw JwkMappingError.missingCurve
    }
    guard let x = jwk.x?.base64UrlEncodedString() else {
      throw JwkMappingError.missingX
    }
    guard let y = jwk.y?.base64UrlEncodedString() else {
      throw JwkMappingError.missingY
    }

    return Components.Schemas.JwkDto(
      kty: jwk.keyType.rawValue,
      kid: try jwk.thumbprint(),
      crv: curve,
      x: x,
      y: y
    )
  }
}
