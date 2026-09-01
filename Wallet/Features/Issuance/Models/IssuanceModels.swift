// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import JSONWebAlgorithms
import JSONWebKey
import JSONWebSignature
import OpenID4VCI

struct CredentialRequest: Codable {
  let credentialConfigurationId: String
  let proofs: JwtProofType
  let credentialResponseEncryption: CredentialResponseEncryptionDTO?

  enum CodingKeys: String, CodingKey {
    case credentialConfigurationId = "credential_configuration_id"
    case credentialResponseEncryption = "credential_response_encryption"
    case proofs
  }

  init(
    credentialConfigurationId: String,
    proofs: JwtProofType,
    credentialResponseEncryption: CredentialResponseEncryptionDTO? = nil,
  ) {
    self.credentialConfigurationId = credentialConfigurationId
    self.proofs = proofs
    self.credentialResponseEncryption = credentialResponseEncryption
  }
}

struct CredentialResponseEncryptionDTO: Codable {
  let jwk: JWK
  let enc: String
}

struct JwtProofType: Codable {
  let jwt: [String]
}

struct NonceResponse: Codable {
  let cNonce: String
}

struct CredentialResponse: Codable {
  let credentials: [CredentialBody]
}

struct CredentialBody: Codable {
  let credential: String
}

struct JwtProofPayload: Codable {
  let aud: String
  let nonce: String?
  var iss: String? = "wallet-app"
}
