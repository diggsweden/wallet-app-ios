// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CryptoKit
import Foundation
import Security

extension P256.Signing.PrivateKey {
  func toSecKey() throws -> SecKey {
    var error: Unmanaged<CFError>?
    let keyData = x963Representation as CFData
    let attributes: [String: Any] = [
      kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
      kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
      kSecAttrKeySizeInBits as String: 256,
    ]
    guard let secKey = SecKeyCreateWithData(keyData, attributes as CFDictionary, &error) else {
      throw error?.takeRetainedValue() ?? KeychainError.conversionFailed
    }
    return secKey
  }
}
