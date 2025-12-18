import Foundation

struct DefaultJWTClaims: Codable {
  let iat: Int
  let nbf: Int
  let exp: Int
}

struct JWTClaims<T: Codable>: Codable {
  let defaults: DefaultJWTClaims
  let payload: T

  func encode(to encoder: Encoder) throws {
    try defaults.encode(to: encoder)
    try payload.encode(to: encoder)
  }
}
