import CryptoKit
import Foundation
import OpenID4VCI

final class DiggSigner: AsyncSignerProtocol {
  let privateKey: P256.Signing.PrivateKey

  init(_ privateKey: P256.Signing.PrivateKey) {
    self.privateKey = privateKey
  }

  func signAsync(_ header: Data, _ payload: Data) async throws -> Data {
    guard
      let jwtData = [header, payload]
        .map({ $0.data().base64URLEncodedString() })
        .joined(separator: ".")
        .data(using: .ascii)
    else {
      throw GenericError(message: "Failed to create JWT header/payload")
    }

    return try privateKey.signature(for: jwtData).rawRepresentation
  }
}
