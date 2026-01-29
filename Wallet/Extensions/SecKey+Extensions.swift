import Foundation
import JOSESwift
import Security

extension SecKey {
  func toECPublicKey(alg: String = KeyManagementAlgorithm.ECDH_ES.rawValue) throws -> ECPublicKey {
    let publicKey = SecKeyCopyPublicKey(self) ?? self

    guard let data = SecKeyCopyExternalRepresentation(publicKey, nil) as Data? else {
      throw AppError(reason: "Failed converting SecKey to data")
    }

    let (x, y) = try P256Point.coordinates(fromX963: data)

    return try ECPublicKey(
      crv: .P256,
      x: x.base64URLEncodedString(),
      y: y.base64URLEncodedString(),
      additionalParameters: ["alg": alg]
    )
    .withThumbprintAsKeyId()
  }
}
