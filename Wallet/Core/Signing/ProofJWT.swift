import CryptoKit
import Foundation
import JOSESwift

struct ProofJWTPayload: Codable {
  let audience: String
  let issuedAt: Date
}

func createProofJWT(from privateKey: P256.Signing.PrivateKey, audience: String) throws -> String {
  let (x, y) = try privateKey.publicKey.getXYCoordinates()

  let jwk = ECPublicKey(
    crv: .P256,
    x: x.base64URLEncodedString(),
    y: y.base64URLEncodedString()
  )

  var header = JWSHeader(algorithm: .ES256)
  header.jwkTyped = jwk

  guard let signer = Signer(signatureAlgorithm: .ES256, key: privateKey.rawRepresentation) else {
    throw GenericError(message: "Failed to create JWT signer")
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
