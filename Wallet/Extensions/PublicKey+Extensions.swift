import CryptoKit
import Foundation

extension P256.Signing.PublicKey {
  func getXYCoordinates() throws -> (x: Data, y: Data) {
    let bytes = self.x963Representation

    guard bytes.first == 0x04, bytes.count == 65 else {
      throw AppError(reason: "Unexpected key format")
    }

    // x: first 32 bytes
    let x = bytes.dropFirst().prefix(32)
    // y: last 32 bytes
    let y = bytes.dropFirst(33)

    return (x: Data(x), y: Data(y))
  }
}
