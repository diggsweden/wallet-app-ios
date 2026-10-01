// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CryptoKit
import Foundation
import Jose
import WalletGatewayInterface

extension P256.Signing.PublicKey {
  func toPublicKeyComponents() throws -> PublicKeyComponents {
    var jwk = WalletJoseJWK(self)
    jwk.keyID = try jwk.thumbprint()
    return try jwk.toPublicKeyComponents()
  }
}

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
