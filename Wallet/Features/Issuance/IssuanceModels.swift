import Foundation
import OpenID4VCI

struct GrantModel: Identifiable {
  let id = UUID()
  let salt: String
  let parameter: String
  let value: String
}

struct CredentialResponseModel: Codable {
  let credential: String
  let cNonce: String?
  let cNonceExpiresIn: String?

  enum CodingKeys: String, CodingKey {
    case credential
    case cNonce = "c_nonce"
    case cNonceExpiresIn = "c_nonce_expires_in"
  }
}

struct CredentialRequestModel: Codable {
  let format: String
  let vct: String
  let proof: Proof
}

struct PidClaim: Identifiable {
  let id = UUID()
  let claim: Claim
  // TODO: Parse value into correct format based on claim.value_type
  let value: String
}
