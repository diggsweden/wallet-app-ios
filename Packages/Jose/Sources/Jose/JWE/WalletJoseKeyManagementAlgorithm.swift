// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

public enum WalletJoseKeyManagementAlgorithm: String, Codable, Sendable {
  // swift-format-ignore: AlwaysUseLowerCamelCase
  case rsa1_5 = "RSA1_5"
  case rsaOAEP = "RSA-OAEP"
  case rsaOAEP256 = "RSA-OAEP-256"
  case a128KW = "A128KW"
  case a192KW = "A192KW"
  case a256KW = "A256KW"
  case direct = "dir"
  case ecdhES = "ECDH-ES"
  case ecdhESA128KW = "ECDH-ES+A128KW"
  case ecdhESA192KW = "ECDH-ES+A192KW"
  case ecdhESA256KW = "ECDH-ES+A256KW"
  case a128GCMKW = "A128GCMKW"
  case a192GCMKW = "A192GCMKW"
  case a256GCMKW = "A256GCMKW"
  case pbes2HS256A128KW = "PBES2-HS256+A128KW"
  case pbes2HS384A192KW = "PBES2-HS384+A192KW"
  case pbes2HS512A256KW = "PBES2-HS512+A256KW"
  case ecdh1PU = "ECDH-1PU"
  case ecdh1PUA128KW = "ECDH-1PU+A128KW"
  case ecdh1PUA192KW = "ECDH-1PU+A192KW"
  case ecdh1PUA256KW = "ECDH-1PU+A256KW"
}
