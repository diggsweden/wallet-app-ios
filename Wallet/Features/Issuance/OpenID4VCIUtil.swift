import Foundation

struct CredentialRequest: Codable {
  let credentialConfigurationId: String
  let proofs: JWTProofType
}

struct CredentialRequestOld: Codable {
  let credentialConfigurationId: String
  let proof: ProofOld
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

struct OpenID4VCIUtil {
  private let encoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    return encoder
  }()

  func fetchCredential(
    url: URL,
    token: String,
    credentialRequest: CredentialRequestOld
  ) async throws -> String {
    let response: CredentialResponse = try await NetworkClient.shared.fetch(
      url,
      method: .post,
      token: token,
      body: try encoder.encode(credentialRequest)
    )
    guard let credential = response.credentials.first else {
      throw AppError(reason: "Could not fetch credential")
    }

    return credential.credential
  }

  func fetchNonce(
    url: URL,
  ) async throws -> String {
    let response: NonceResponse = try await NetworkClient.shared.fetch(
      url,
      method: .post
    )
    return response.cNonce
  }
}
