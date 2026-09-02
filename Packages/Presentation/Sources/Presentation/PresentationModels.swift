// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import eudi_lib_sdjwt_swift

struct RedirectUrl: Decodable {
  let redirectUri: String?
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

struct CredentialQuery {
  let id: String
  let claimPaths: Set<ClaimPath>
  let required: Bool
  let vctValues: [String]
}

struct PresentationRequestData {
  let credentialQueries: [CredentialQuery]
  let responseUrl: URL
  let clientId: String
  let nonce: String
  let state: String?
}
