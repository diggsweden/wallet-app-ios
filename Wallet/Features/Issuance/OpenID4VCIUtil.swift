// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import JOSESwift

struct CryptoSpec {
  let key: JWK
  let enc: ContentEncryptionAlgorithm
}

struct OpenID4VCIUtil {
  private let jwtUtil = JWTUtil()
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
    credentialRequest: CredentialRequest,
    requestEncryption: CryptoSpec,
    responseDecryption: CryptoSpec,
  ) async throws -> String {
    let jwe = try jwtUtil.encryptJWE(
      payload: credentialRequest,
      recipientKey: requestEncryption.key,
      enc: requestEncryption.enc
    )

    let encryptedResponse = try await NetworkClient.shared.fetchJwt(
      url,
      method: .post,
      contentType: "application/jwt",
      accept: "application/jwt",
      token: token,
      body: jwe.utf8Data
    )

    let response: CredentialResponse = try jwtUtil.decryptJWE(
      encryptedResponse,
      decryptionKey: responseDecryption.key,
      enc: responseDecryption.enc
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
