import CryptoKit
import Foundation
import Security

final class KeychainManager {
  private let keyType = kSecAttrKeyTypeECSECPrimeRandom
  private let keySize = 256

  static let shared = KeychainManager()

  func generateKey(withTag tag: String) throws -> SecKey {
    var attributes: [String: Any] = [
      kSecAttrKeyType as String: keyType,
      kSecAttrKeySizeInBits as String: keySize,
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
      throw error?.takeRetainedValue() ?? KeychainManagerError.keyGenerationFailed
    }

    return privateKey
  }

  func fetchKey(withTag tag: String) throws -> SecKey {
    let query: [String: Any] = [
      kSecClass as String: kSecClassKey,
      kSecAttrApplicationTag as String: tag.utf8Data,
      kSecAttrKeyType as String: keyType,
      kSecReturnRef as String: true,
    ]

    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)

    guard status == errSecSuccess, let key = item else {
      throw KeychainManagerError.keyNotFound
    }

    // swift-format-ignore
    return key as! SecKey
  }

  func deleteKey(withTag tag: String) throws {
    let query: [String: Any] = [
      kSecClass as String: kSecClassKey,
      kSecAttrApplicationTag as String: tag.utf8Data,
      kSecAttrKeyType as String: keyType,
    ]

    let status = SecItemDelete(query as CFDictionary)

    switch status {
      case errSecSuccess, errSecItemNotFound:
        return
      default:
        throw KeychainManagerError.keychainError(status)
    }
  }

  func getOrCreateKey(withTag tag: String) throws -> SecKey {
    return if let existingKey = try? fetchKey(withTag: tag) {
      existingKey
    } else {
      try generateKey(withTag: tag)
    }
  }

  private var isSimulator: Bool {
    #if targetEnvironment(simulator)
      return true
    #else
      return false
    #endif
  }
}
