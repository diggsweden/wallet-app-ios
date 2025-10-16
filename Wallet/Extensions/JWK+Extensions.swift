import Foundation
import JOSESwift
import SiopOpenID4VP

extension JWK {
  func toDictionary() -> [String: Any] {
    var dict = self.parameters
    if let ecPublicKey = self as? ECPublicKey {
      dict["crv"] = ecPublicKey.crv.rawValue
      dict["x"] = ecPublicKey.x
      dict["y"] = ecPublicKey.y
    }
    return dict
  }
}

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
