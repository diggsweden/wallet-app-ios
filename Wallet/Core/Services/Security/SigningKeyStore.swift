// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CryptoKit
import Foundation
import Security

enum SigningKeyStore {
  enum KeyTag: String, CaseIterable {
    case deviceKey = "device_key"
    case walletKey = "wallet_key"

    var keychainAccount: String { rawValue }
  }

  private static let keychainService = "se.digg.wallet.keys"

  static func getOrCreateKey(withTag tag: KeyTag) throws -> SecureEnclave.P256.Signing.PrivateKey {
    if let existing = try? fetchKey(withTag: tag) {
      return existing
    }
    return try generateKey(withTag: tag)
  }

  static func deleteAll() throws {
    for tag in KeyTag.allCases {
      try deleteKey(withTag: tag)
    }
  }

  private static func generateKey(
    withTag tag: KeyTag
  ) throws -> SecureEnclave.P256.Signing.PrivateKey {
    let key = try SecureEnclave.P256.Signing.PrivateKey()
    try storeKeyData(key.dataRepresentation, forTag: tag)
    return key
  }

  private static func fetchKey(withTag tag: KeyTag) throws -> SecureEnclave.P256.Signing.PrivateKey
  {
    let data = try fetchKeyData(forTag: tag)
    return try SecureEnclave.P256.Signing.PrivateKey(dataRepresentation: data)
  }

  private static func storeKeyData(_ data: Data, forTag tag: KeyTag) throws {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: keychainService,
      kSecAttrAccount as String: tag.keychainAccount,
      kSecValueData as String: data,
      kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
      kSecAttrSynchronizable as String: false,
    ]

    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else {
      throw KeychainError.keychainError(status)
    }
  }

  private static func fetchKeyData(forTag tag: KeyTag) throws -> Data {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: keychainService,
      kSecAttrAccount as String: tag.keychainAccount,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne,
    ]

    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)

    guard status == errSecSuccess, let data = item as? Data else {
      throw KeychainError.keyNotFound
    }

    return data
  }

  private static func deleteKey(withTag tag: KeyTag) throws {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: keychainService,
      kSecAttrAccount as String: tag.keychainAccount,
    ]

    let status = SecItemDelete(query as CFDictionary)
    guard status == errSecSuccess || status == errSecItemNotFound else {
      throw KeychainError.keychainError(status)
    }
  }
}
