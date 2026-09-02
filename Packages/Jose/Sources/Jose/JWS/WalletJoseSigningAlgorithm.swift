// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

// swift-format-ignore-file: AlwaysUseLowerCamelCase
// swiftlint:disable identifier_name

public enum WalletJoseSigningAlgorithm: String, Codable, Sendable {
  case HS256
  case HS384
  case HS512
  case RS256
  case RS384
  case RS512
  case ES256
  case ES384
  case ES512
  case ES256K
  case PS256
  case PS384
  case PS512
  case EdDSA
  case none
  case invalid
}

// swiftlint:enable identifier_name
