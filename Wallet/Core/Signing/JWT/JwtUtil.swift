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

  /// Builds the JWT signing input from the payload and header, delegates the
  /// actual signing to `sign`, and returns the complete compact-serialized JWT.
  ///
  /// - Parameters sign: Receives the signing-input bytes and returns the
  ///   base64url-encoded signature. This lets the caller sign with any backend
  ///   (Secure Enclave, remote HSM, ...) without `JwtUtil` knowing about keys.
  func signJwt<T: Codable>(
    payload: T,
    header: JWSRegisteredFieldsHeader = DefaultJWSHeaderImpl(algorithm: .ES256),
    sign: sending (Data) async throws -> String,
  ) async throws -> String {
    let now = Int(Date().timeIntervalSince1970)
    let defaults = DefaultJwtClaims(iat: now, nbf: now, exp: now + ttlSeconds)
    let claims = JwtClaims(defaults: defaults, payload: payload)

    let headerB64 = try jsonEncoder.encode(header).base64UrlEncodedString()
    let payloadB64 = try jsonEncoder.encode(claims).base64UrlEncodedString()

    let signingInput = "\(headerB64).\(payloadB64)"
    guard let signingInputData = signingInput.data(using: .ascii) else {
      throw JwtSigningError.encodingFailed
    }

    let signature = try await sign(signingInputData)
    return "\(signingInput).\(signature)"
  }

  /// Signs a JWT with a Secure Enclave key.
  func signJwt<T: Codable>(
    with key: SecureEnclave.P256.Signing.PrivateKey,
    payload: T,
    header: JWSRegisteredFieldsHeader = DefaultJWSHeaderImpl(algorithm: .ES256),
  ) async throws -> String {
    try await signJwt(payload: payload, header: header) { signingInput in
      try key.signature(for: signingInput).rawRepresentation.base64UrlEncodedString()
    }
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
        recipientKey: recipientKey,
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
