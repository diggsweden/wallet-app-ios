// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CryptoKit
import Foundation
import JOSESwift
import OpenID4VP

struct JWTUtil {
  private let ttlSeconds: Int = 600
  private let jsonEncoder: JSONEncoder = {
    let decoder = JSONEncoder()
    decoder.keyEncodingStrategy = .convertToSnakeCase
    return decoder
  }()
  private let jsonDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()

  func signJWT<T: Codable>(
    with key: SecKey,
    payload: T,
    headers: [String: Any] = [:],
    includeJWK: Bool = true
  ) throws -> String {
    let now = Int(Date().timeIntervalSince1970)
    let defaults = DefaultJWTClaims(iat: now, nbf: now, exp: now + ttlSeconds)
    let claims = JWTClaims(defaults: defaults, payload: payload)
    let payloadData = try jsonEncoder.encode(claims)
    let josePayload = Payload(payloadData)
    let alg = SignatureAlgorithm.ES256

    var headerParams: [String: Any] = ["alg": alg.rawValue]
    headers.forEach {
      headerParams[$0.key] = $0.value
    }

    var header = try JWSHeader(parameters: headerParams)

    if includeJWK {
      header.jwkTyped = try key.toECPublicKey(alg: alg.rawValue)
    }

    guard let signer = Signer(signatureAlgorithm: alg, key: key) else {
      throw JWTError.invalidSigner
    }

    let jws = try JWS(header: header, payload: josePayload, signer: signer)
    return jws.compactSerializedString
  }

  func encryptJWE<T: Codable>(
    payload: T,
    recipientKey: JWK,
    alg: KeyManagementAlgorithm = .ECDH_ES,
    enc: ContentEncryptionAlgorithm = .A128GCM,
  ) throws -> String {
    let header = JWEHeader(
      keyManagementAlgorithm: alg,
      contentEncryptionAlgorithm: enc
    )

    guard
      let encrypter = Encrypter(
        keyManagementAlgorithm: alg,
        contentEncryptionAlgorithm: enc,
        encryptionKey: recipientKey
      )
    else {
      throw JWTError.invalidEncrypter
    }

    let data = try jsonEncoder.encode(payload)
    let jwe = try JWE(header: header, payload: Payload(data), encrypter: encrypter)
    return jwe.compactSerializedString
  }

  func decryptJWE<T: Decodable>(
    _ compactString: String,
    decryptionKey: JWK,
    alg: KeyManagementAlgorithm = .ECDH_ES,
    enc: ContentEncryptionAlgorithm = .A128GCM,
  ) throws -> T {
    let jwe = try JWE(compactSerialization: compactString)

    guard
      let decrypter = Decrypter(
        keyManagementAlgorithm: alg,
        contentEncryptionAlgorithm: enc,
        decryptionKey: decryptionKey
      )
    else {
      throw JWTError.invalidDecrypter
    }

    let payload = try jwe.decrypt(using: decrypter)
    let s = String(decoding: payload.data(), as: UTF8.self)
    return try jsonDecoder.decode(T.self, from: payload.data())
  }

  static func base64UrlDecode(_ base64url: String) -> Data? {
    var base64 =
      base64url
      .replacingOccurrences(of: "-", with: "+")
      .replacingOccurrences(of: "_", with: "/")

    let paddingLength = 4 - (base64.count % 4)
    if paddingLength < 4 {
      base64.append(String(repeating: "=", count: paddingLength))
    }

    return Data(base64Encoded: base64)
  }
}
