import CryptoKit
import Foundation
import JOSESwift
import OpenID4VP

struct JWTUtil {
  static private func createPayload(initial payload: [String: Any]) throws -> Payload {
    var payload = payload
    for (key, value) in payload {
      if let dataValue = value as? Data,
        let jsonObject = try? JSONSerialization.jsonObject(with: dataValue, options: [])
      {
        payload[key] = jsonObject
      }
    }

    let payloadData = try JSONSerialization.data(withJSONObject: payload)
    return Payload(payloadData)
  }

  static func createJWT(
    with key: SecKey,
    headers: [String: Any] = [:],
    payload: [String: Any],
  ) throws -> String {
    let jwk = try key.toECPublicKey()

    let headerParams = [
      "alg": SignatureAlgorithm.ES256.rawValue
    ]
    .merging(headers) { (_, new) in new }

    var header = try JWSHeader(parameters: headerParams)
    header.jwkTyped = jwk

    guard let signer = Signer(signatureAlgorithm: .ES256, key: key) else {
      throw JWTError.invalidSigner
    }

    let now = Int(Date().timeIntervalSince1970)

    let payload = [
      "iat": now,
      "nbf": now,
      "exp": now + 600,
    ]
    .merging(payload) { (_, new) in new }

    let jws = try JWS(
      header: header,
      payload: try createPayload(initial: payload),
      signer: signer
    )

    return jws.compactSerializedString
  }

  static func createJWE(
    payload: [String: Any],
    recipientKey: ECPublicKey
  ) throws -> String {
    let header = JWEHeader(
      keyManagementAlgorithm: .ECDH_ES,
      contentEncryptionAlgorithm: .A128GCM
    )

    let encrypter = Encrypter(
      keyManagementAlgorithm: .ECDH_ES,
      contentEncryptionAlgorithm: .A128GCM,
      encryptionKey: recipientKey
    )

    guard let encrypter = encrypter else {
      throw JWTError.invalidJWE
    }

    let jwe = try JWE(
      header: header,
      payload: try createPayload(initial: payload),
      encrypter: encrypter
    )

    return jwe.compactSerializedString
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
