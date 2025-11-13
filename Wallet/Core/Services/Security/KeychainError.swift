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
        return "Failed to generate key"
      case .keyNotFound:
        return "Key not found in keychain"
      case .keychainError(let status):
        return "Keychain error: \(status)"
      case .conversionFailed:
        return "Failed to convert between key formats"
      case .invalidKeyData:
        return "Invalid key data format"
    }
  }
}
