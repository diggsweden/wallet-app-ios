import CryptoKit
import Foundation
import JOSESwift

struct ProofJWTPayload: Codable {
  let audience: String
  let issuedAt: Date
}

struct JWTParts {
  let header: Data
  let payload: Data
  let signature: String
}

struct JWTUtil {
  static func parseJWT(_ token: String) throws -> JWTParts {
    let parts = token.components(separatedBy: ".")

    guard parts.count == 3 else {
      throw JWTError.invalidFormat
    }

    let headerString = parts[0]
    let payloadString = parts[1]
    let signatureString = parts[2]

    guard let headerData = base64UrlDecode(headerString),
      let payloadData = base64UrlDecode(payloadString)
    else {
      throw JWTError.invalidBase64
    }

    return JWTParts(
      header: headerData,
      payload: payloadData,
      signature: signatureString
    )
  }

  static func createProofJWT(
    from privateKey: P256.Signing.PrivateKey,
    audience: String
  ) throws -> String {
    let (x, y) = try privateKey.publicKey.getXYCoordinates()

    let jwk = ECPublicKey(
      crv: .P256,
      x: x.base64URLEncodedString(),
      y: y.base64URLEncodedString()
    )

    var header = JWSHeader(algorithm: .ES256)
    header.jwkTyped = jwk

    guard let signer = Signer(signatureAlgorithm: .ES256, key: privateKey.rawRepresentation) else {
      throw JWTError.invalidSigner
    }

    let payload = ProofJWTPayload(
      audience: audience,
      issuedAt: Date()
    )

    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .secondsSince1970
    let payloadData = try encoder.encode(payload)

    let jws = try JWS(
      header: header,
      payload: Payload(payloadData),
      signer: signer
    )

    return jws.compactSerializedString
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
