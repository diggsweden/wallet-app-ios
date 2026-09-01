// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

struct DefaultJwtClaims: Codable {
  let iat: Int
  let nbf: Int
  let exp: Int
}

struct JwtClaims<T: Codable>: Codable {
  let defaults: DefaultJwtClaims
  let payload: T

  func encode(to encoder: Encoder) throws {
    try defaults.encode(to: encoder)
    try payload.encode(to: encoder)
  }
}
