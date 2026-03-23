// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import JSONWebKey
import eudi_lib_sdjwt_swift

enum PresentationPhase {
  case loading
  case error
  case ready
}

enum PresentationRoute: Hashable {
  case pin
  case success
}

enum PresentationError: Error {
  case noCredential
  case noRequestData
  case noMatchingClaims
  case resolutionFailed(String)
  case unsupportedQuery
  case unsupportedResponseMode
  case jweEncryptionFailed
  case keyBindingEncodingFailed
}

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
}

struct PresentationItem: Identifiable {
  let id: String
  let required: Bool
  let claims: [ClaimUiModel]
  let disclosedSdJwt: SignedSDJWT
  var isSelected: Bool
}

struct PresentationResult {
  let redirectUrl: URL?
}

struct PresentationRequestData {
  let credentialQueries: [CredentialQuery]
  let responseUrl: URL
  let clientId: String
  let nonce: String
  let state: String?
  let recipientJWK: JWK?
}
