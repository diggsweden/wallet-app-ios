// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Jose
import SwiftAccessMechanism
import WalletGatewayInterface

extension WalletJoseJWK {
  func toPublicKeyComponents() throws -> PublicKeyComponents {
    guard
      let kid = keyID,
      let curve = curve?.rawValue,
      let x = x?.base64UrlEncodedString(),
      let y = y?.base64UrlEncodedString()
    else {
      throw AppError(reason: "Invalid key format")
    }
    return PublicKeyComponents(
      kty: keyType.rawValue,
      kid: kid,
      crv: curve,
      x: x,
      y: y,
    )
  }
}

extension WalletJoseJWK {
  init(_ jwkKey: JwkKey) throws {
    guard
      let keyType = WalletJoseKeyType(rawValue: jwkKey.kty),
      let curve = WalletJoseCurve(rawValue: jwkKey.crv),
      let x = Data(base64UrlEncoded: jwkKey.x),
      let y = Data(base64UrlEncoded: jwkKey.y)
    else {
      throw AppError(reason: "Invalid key format")
    }

    self.init(
      keyType: keyType,
      curve: curve,
      keyID: jwkKey.kid,
      x: x,
      y: y,
    )
  }
}
