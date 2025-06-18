import Foundation

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

struct Proof: Codable {
  // swift-format-ignore
  let proof_type: String
  let jwt: String
}

struct CredentialRequestModel: Codable {
  let format: String
  let vct: String
  let proof: Proof
}
