// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Jose

enum JwtDecodingError: Error {
  case malformed
}

struct DecodedJwt {
  let header: [String: Any]
  let claims: [String: Any]
  let signingInput: Data
  let signature: Data

  init(compact: String) throws {
    let parts = compact.split(separator: ".")

    guard
      parts.count == 3,
      let headerData = Data(base64UrlEncoded: String(parts[0])),
      let claimsData = Data(base64UrlEncoded: String(parts[1])),
      let signature = Data(base64UrlEncoded: String(parts[2])),
      let header = try JSONSerialization.jsonObject(with: headerData) as? [String: Any],
      let claims = try JSONSerialization.jsonObject(with: claimsData) as? [String: Any],
      let signingInput = "\(parts[0]).\(parts[1])".data(using: .ascii)
    else {
      throw JwtDecodingError.malformed
    }

    self.header = header
    self.claims = claims
    self.signingInput = signingInput
    self.signature = signature
  }
}
