// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import Foundation
import Jose
import OpenId4VCInterface
import Trust

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

  enum CodingKeys: String, CodingKey {
    case state, nonce
    case vpToken = "vp_token"
  }
}

struct CredentialQuery {
  let id: String
  let format: String
  let claimPaths: Set<ClaimPath>
  let required: Bool
  let vctValues: Set<String>
}

struct PresentationRequestData {
  let credentialQueries: [CredentialQuery]
  let responseUrl: URL
  let clientId: String
  let nonce: String
  let state: String?
  let encryption: CryptoSpec?
  let registrationCertificates: [RegistrationCertificate]
  let legalName: String?
}

struct ParsedRegistrationCertificate {
  let requestableCredentials: [RequestableCredential]
  let verifierUiModel: VerifierUiModel
}
