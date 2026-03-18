// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import JSONWebKey
import OpenID4VP

extension WebKeySet.Key {
  func toJWK() throws -> JWK {
    guard
      kty == "EC",
      crv == "P-256",
      let x,
      let y
    else {
      throw AppError(reason: "Unsupported key type")
    }

    guard
      let xData = Data(base64UrlEncoded: x),
      let yData = Data(base64UrlEncoded: y)
    else {
      throw AppError(reason: "Invalid key coordinate data")
    }

    return JWK(
      keyType: .ellipticCurve,
      keyID: kid,
      curve: .p256,
      x: xData,
      y: yData
    )
  }
}
