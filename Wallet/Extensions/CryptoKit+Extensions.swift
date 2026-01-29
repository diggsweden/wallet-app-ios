import CryptoKit
import Foundation
import JOSESwift

extension P256.KeyAgreement.PublicKey {
  func toECPublicKey(
    alg: String = KeyManagementAlgorithm.ECDH_ES.rawValue
  ) throws -> ECPublicKey {
    let (x, y) = try P256Point.coordinates(fromX963: self.x963Representation)

    return try ECPublicKey(
      crv: .P256,
      x: x.base64URLEncodedString(),
      y: y.base64URLEncodedString(),
      additionalParameters: ["alg": alg]
    )
    .withThumbprintAsKeyId()
  }
}

extension P256.KeyAgreement.PrivateKey {
  func toECPrivateKey(
    alg: String = KeyManagementAlgorithm.ECDH_ES.rawValue
  ) throws -> ECPrivateKey {
    let (x, y) = try P256Point.coordinates(fromX963: self.publicKey.x963Representation)
    let privateKeyString = self.rawRepresentation.base64URLEncodedString()

    return try ECPrivateKey(
      crv: ECCurveType.P256.rawValue,
      x: x.base64URLEncodedString(),
      y: y.base64URLEncodedString(),
      privateKey: privateKeyString,
      additionalParameters: ["alg": alg]
    )
    .withThumbprintAsKeyId()
  }
}
