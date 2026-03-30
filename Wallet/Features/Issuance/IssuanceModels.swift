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
  let credentialResponseEncryption: CredentialResponseEncryptionDTO?
  let proofs: JwtProofType

  enum CodingKeys: String, CodingKey {
    case credentialConfigurationId = "credential_configuration_id"
    case credentialResponseEncryption = "credential_response_encryption"
    case proofs
  }

  init(
    credentialConfigurationId: String,
    proofs: JwtProofType,
    credentialResponseEncryption: CredentialResponseEncryptionDTO? = nil
  ) {
    self.credentialConfigurationId = credentialConfigurationId
    self.credentialResponseEncryption = credentialResponseEncryption
    self.proofs = proofs
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

struct PidClaim: Identifiable {
  let id = UUID()
  let claim: Claim
  // Parse value into correct format based on claim.value_type
  let value: String
}

struct JwtProofPayload: Codable {
  let nonce: String?
  let aud: String
}

struct KeyAttestationHeader: JWSRegisteredFieldsHeader {
  var algorithm: JSONWebAlgorithms.SigningAlgorithm? = .ES256
  var jwkSetURL: String?
  var jwk: JSONWebKey.JWK?
  var keyID: String?
  var x509URL: String?
  var x509CertificateChain: [String]?
  var x509CertificateSHA1Thumbprint: String?
  var x509CertificateSHA256Thumbprint: String?
  var type: String? = "openid4vci-proof+jwt"
  var contentType: String?
  var critical: [String]?
  var base64EncodedUrlPayload: Bool?  // swiftlint:disable:this discouraged_optional_boolean
  let keyAttestation: String?

  enum CodingKeys: String, CodingKey {
    case algorithm = "alg"
    case jwkSetURL = "jku"
    case jwk
    case keyID = "kid"
    case x509URL = "x5u"
    case x509CertificateChain = "x5c"
    case x509CertificateSHA1Thumbprint = "x5t"
    case x509CertificateSHA256Thumbprint = "x5t#S256"
    case type = "typ"
    case contentType = "cty"
    case critical = "crit"
    case base64EncodedUrlPayload = "b64"
    case keyAttestation = "key_attestation"
  }
}
