import Foundation
import JOSESwift
import SiopOpenID4VP

extension WebKeySet.Key {
  func toEcPublicKey() throws -> ECPublicKey {
    guard
      kty == "EC",
      crv == "P-256",
      let x,
      let y,
      let use,
      let kid
    else {
      throw AppError(reason: "Unsupported key type")
    }

    return ECPublicKey(
      crv: .P256,
      x: x,
      y: y,
      additionalParameters: [
        "use": use,
        "kid": kid,
        "alg": alg ?? "ECDH-ES",
      ]
    )
  }
}
