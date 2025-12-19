import Foundation

struct OpenID4VCIUtil {
  private let encoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    return encoder
  }()

  func fetchCredential(
    url: URL,
    token: String,
    credentialRequest: CredentialRequest
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

  func fetchCredential(
    url: URL,
    token: String,
    jwe: String,
  ) async throws -> String {
    return try await NetworkClient.shared.fetchJwt(
      url,
      method: .post,
      contentType: "application/jwt",
      accept: "application/jwt",
      token: token,
      body: jwe.utf8Data
    )
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
