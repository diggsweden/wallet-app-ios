import Foundation
import JOSESwift
import OpenID4VCI

struct CredentialRequest: Codable {
  let credentialConfigurationId: String
  let credentialResponseEncryption: CredentialResponseEncryptionDTO?
  let proofs: JWTProofType

  init(
    credentialConfigurationId: String,
    credentialResponseEncryption: CredentialResponseEncryptionDTO? = nil,
    proofs: JWTProofType
  ) {
    self.credentialConfigurationId = credentialConfigurationId
    self.credentialResponseEncryption = credentialResponseEncryption
    self.proofs = proofs
  }
}

struct CredentialResponseEncryptionDTO: Codable {
  let jwk: ECPublicKey
  let enc: String
}

struct ProofOld: Codable {
  let jwt: String
  let proofType: String
}

struct JWTProofType: Codable {
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
  // TODO: Parse value into correct format based on claim.value_type
  let value: String
}

struct JWTProofPayload: Codable {
  let nonce: String
  let aud: String
}
