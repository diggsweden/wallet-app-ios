import Foundation
import JOSESwift
import Security

extension SecKey {
  func getP256Coordinates() throws -> (x: Data, y: Data) {
    let publicKey = SecKeyCopyPublicKey(self) ?? self

    guard
      let bytes = SecKeyCopyExternalRepresentation(publicKey, nil) as Data?,
      bytes.first == 0x04,
      bytes.count == 65
    else {
      throw AppError(message: "Failed getting P256 coordinates for public key")
    }

    // x: first 32 bytes
    let x = bytes.dropFirst().prefix(32)
    // y: last 32 bytes
    let y = bytes.dropFirst(33)

    return (Data(x), Data(y))
  }

  func getJWKCoordinates() throws -> (x: String, y: String) {
    let (xData, yData) = try getP256Coordinates()
    return (
      x: xData.base64URLEncodedString(),
      y: yData.base64URLEncodedString()
    )
  }

  func toJWK() throws -> JWK {
    let (x, y) = try getJWKCoordinates()
    return ECPublicKey(
      crv: .P256,
      x: x,
      y: y,
      additionalParameters: [
        "kid": Constants.bindingKeyTag
      ]
    )
  }
}
