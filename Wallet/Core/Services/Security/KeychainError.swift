// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Security

enum KeychainError: Error {
  case keyGenerationFailed
  case keyNotFound
  case keychainError(OSStatus)
  case conversionFailed
  case invalidKeyData

  var localizedDescription: String {
    switch self {
      case .keyGenerationFailed:
        "Failed to generate key"

      case .keyNotFound:
        "Key not found in keychain"

      case .keychainError(let status):
        "Keychain error: \(status)"

      case .conversionFailed:
        "Failed to convert between key formats"

      case .invalidKeyData:
        "Invalid key data format"
    }
  }
}
