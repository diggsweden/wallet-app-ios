// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CryptoKit
import Foundation
import JSONWebAlgorithms
import JSONWebEncryption
import JSONWebKey
import JSONWebSignature
import JSONWebToken

enum JwtSigningError: Error {
  case encodingFailed
}

struct JwtUtil {
  private let ttlSeconds: Int = 600
  private let jsonEncoder = JSONEncoder()
  private let jsonDecoder = JSONDecoder()

  func signJwt<T: Codable>(
    with key: SecureEnclave.P256.Signing.PrivateKey,
    payload: T,
    header: JWSRegisteredFieldsHeader = DefaultJWSHeaderImpl(algorithm: .ES256)
  ) throws -> String {
    let now = Int(Date().timeIntervalSince1970)
    let defaults = DefaultJwtClaims(iat: now, nbf: now, exp: now + ttlSeconds)
    let claims = JwtClaims(defaults: defaults, payload: payload)

    let headerData = try jsonEncoder.encode(header)
    let payloadData = try jsonEncoder.encode(claims)

    let headerB64 = headerData.base64UrlEncodedString()
    let payloadB64 = payloadData.base64UrlEncodedString()

    let signingInput = "\(headerB64).\(payloadB64)"
    guard let signingInputData = signingInput.data(using: .ascii) else {
      throw JwtSigningError.encodingFailed
    }

    let signature = try key.signature(for: signingInputData)
    let signatureB64 = signature.rawRepresentation.base64UrlEncodedString()

    return "\(signingInput).\(signatureB64)"
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
