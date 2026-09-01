// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CryptoKit
import Foundation

@testable import WalletDemo

enum JwtDecodingError: Error {
  case malformed
}

/// A compact-serialized JWT taken apart so tests can assert on what was signed.
struct DecodedJwt {
  let header: [String: Any]
  let claims: [String: Any]

  /// The bytes covered by the signature, i.e. `header.claims` in base64url.
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

  func headerString(_ name: String) -> String? {
    header[name] as? String
  }

  func claim(_ name: String) -> String? {
    claims[name] as? String
  }

  /// The `jwk` the header advertises as the verification key.
  var jwk: [String: Any]? {
    header["jwk"] as? [String: Any]
  }

  /// Whether the signature verifies under the key the header advertises, which
  /// is what a server checks: it has nothing but the proof itself to go on.
  func verifiesWithAdvertisedKey() throws -> Bool {
    guard
      let jwk,
      let x = (jwk["x"] as? String).flatMap({ Data(base64UrlEncoded: $0) }),
      let y = (jwk["y"] as? String).flatMap({ Data(base64UrlEncoded: $0) })
    else {
      throw JwtDecodingError.malformed
    }

    let publicKey = try P256.Signing.PublicKey(rawRepresentation: x + y)
    let signature = try P256.Signing.ECDSASignature(rawRepresentation: signature)

    return publicKey.isValidSignature(signature, for: signingInput)
  }
}
