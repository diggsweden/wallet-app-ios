import Foundation

enum P256JWKError: Error {
  case invalidKeyFormat
}

enum P256Point {
  static func coordinates(fromX963 data: Data) throws -> (x: Data, y: Data) {
    guard
      data.first == 0x04,
      data.count == 65
    else {
      throw P256JWKError.invalidKeyFormat
    }

    // x: first 32 bytes
    let x = data.dropFirst().prefix(32)
    // y: last 32 bytes
    let y = data.dropFirst(33)

    return (Data(x), Data(y))
  }
}
