// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import JSONWebAlgorithms
import JSONWebEncryption
import JSONWebKey
import JSONWebSignature
import JSONWebToken

struct JwtUtil {
  private let ttlSeconds: Int = 600
  private let jsonEncoder = JSONEncoder()
  private let jsonDecoder = JSONDecoder()

  func signJwt<T: Codable>(
    with key: some KeyRepresentable,
    payload: T,
    header: JWSRegisteredFieldsHeader = DefaultJWSHeaderImpl(algorithm: .ES256),
    includeJWK: Bool = true
  ) throws -> String {
    let now = Int(Date().timeIntervalSince1970)
    let defaults = DefaultJwtClaims(iat: now, nbf: now, exp: now + ttlSeconds)
    let claims = JwtClaims(defaults: defaults, payload: payload)
    return try JWT.signed(payload: claims, protectedHeader: header, key: key).jwtString
  }

  func encryptJwe<T: Codable>(
    payload: T,
    recipientKey: JWK,
    alg: KeyManagementAlgorithm = .ecdhES,
    enc: ContentEncryptionAlgorithm = .a128GCM,
  ) throws -> String {
    let data = try jsonEncoder.encode(payload)

    return
      try JWT.encrypt(
        payload: data,
        keyManagementAlg: alg,
        encryptionAlgorithm: enc,
        recipientKey: recipientKey
      )
      .jwtString
  }

  func decryptJwe<T: Decodable>(
    _ compactString: String,
    decryptionKey: JWK,
  ) throws -> T {
    let jwe = try JWE(compactString: compactString)
    let payload = try jwe.decrypt(recipientKey: decryptionKey)
    return try jsonDecoder.decode(T.self, from: payload)
  }

  static func base64UrlDecode(_ base64url: String) -> Data? {
    Data(base64UrlEncoded: base64url)
  }
}
