// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

struct RedirectUrl: Decodable {
  let redirectUri: String

  enum CodingKeys: String, CodingKey {
    case redirectUri = "redirectUri"
  }
}

struct KeyBindingPayload: Codable {
  let aud: String
  let nonce: String
  let sdHash: String

  enum CodingKeys: String, CodingKey {
    case aud
    case nonce
    case sdHash = "sd_hash"
  }
}

struct VerifiablePresentationToken: Codable {
  let state: String?
  let nonce: String
  let vpToken: [String: [String]]
}
