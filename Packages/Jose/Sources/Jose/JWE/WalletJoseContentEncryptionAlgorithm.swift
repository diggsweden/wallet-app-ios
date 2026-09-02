// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

public enum WalletJoseContentEncryptionAlgorithm: String, Codable, Sendable {
  case a128CBCHS256 = "A128CBC-HS256"
  case a192CBCHS384 = "A192CBC-HS384"
  case a256CBCHS512 = "A256CBC-HS512"
  case a128GCM = "A128GCM"
  case a192GCM = "A192GCM"
  case a256GCM = "A256GCM"
  case c20P = "C20P"
  case xC20P = "XC20P"
}
