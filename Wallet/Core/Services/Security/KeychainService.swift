// SPDX-FileCopyrightText: 2026 diggsweden/wallet-app-ios
//
// SPDX-License-Identifier: EUPL-1.2

import CryptoKit
import Foundation
import Security

enum KeychainService {
  enum KeyTag: String, CaseIterable {
    case deviceKey = "device_key_tag"
    case walletKey = "wallet_key_tag"
  }

  static func getOrCreateKey(withTag tag: KeyTag) throws -> SecKey {
    return if let existingKey = try? fetchKey(withTag: tag.rawValue) {
      existingKey
    } else {
      try generateKey(withTag: tag.rawValue)
    }
  }

  static func deleteAll() throws {
    for tag in KeyTag.allCases {
      try deleteKey(withTag: tag.rawValue)
    }
  }

  static private func deleteKey(withTag tag: String) throws {
    let query: [String: Any] = [
      kSecClass as String: kSecClassKey,
      kSecAttrApplicationTag as String: tag.utf8Data,
      kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
    ]

    let status = SecItemDelete(query as CFDictionary)

    guard status == errSecSuccess || status == errSecItemNotFound else {
      throw KeychainError.keychainError(status)
    }
  }

  static private func generateKey(withTag tag: String) throws -> SecKey {
    var attributes: [String: Any] = [
      kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
      kSecAttrKeySizeInBits as String: 256,
      kSecPrivateKeyAttrs as String: [
        kSecAttrIsPermanent as String: true,
        kSecAttrApplicationTag as String: tag.utf8Data,
        kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
      ],
    ]

    if !isSimulator {
      attributes[kSecAttrTokenID as String] = kSecAttrTokenIDSecureEnclave
    }

    var error: Unmanaged<CFError>?
    guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
      throw error?.takeRetainedValue() ?? KeychainError.keyGenerationFailed
    }

    return privateKey
  }

  static private func fetchKey(withTag tag: String) throws -> SecKey {
    let query: [String: Any] = [
      kSecClass as String: kSecClassKey,
      kSecAttrApplicationTag as String: tag.utf8Data,
      kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
      kSecReturnRef as String: true,
    ]

    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)

    guard status == errSecSuccess, let key = item else {
      throw KeychainError.keyNotFound
    }

    // swift-format-ignore
    return key as! SecKey
  }

  static private var isSimulator: Bool {
    #if targetEnvironment(simulator)
      return true
    #else
      return false
    #endif
  }
}
