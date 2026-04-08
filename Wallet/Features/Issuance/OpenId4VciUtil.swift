// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Crypto
import Foundation
import JSONWebAlgorithms
import JSONWebKey

struct CryptoSpec {
  let key: JWK
  let enc: ContentEncryptionAlgorithm
}

struct OpenId4VciUtil {
  private let jwtUtil = JwtUtil()
  private let encoder = JSONEncoder()

  func fetchCredential(
    url: URL,
    token: String,
    credentialRequest: CredentialRequest,
    requestEncryption: CryptoSpec? = nil
  ) async throws -> String {
    guard let requestEncryption else {
      return try await fetchPlainCredential(
        url: url,
        token: token,
        credentialRequest: credentialRequest
      )
    }

    let ephemeralKey = P256.KeyAgreement.PrivateKey()
    let enc = requestEncryption.enc

    var responseJwk = ephemeralKey.publicKey.jwkRepresentation
    responseJwk.algorithm = KeyManagementAlgorithm.ecdhES.rawValue

    let encryptedRequest = CredentialRequest(
      credentialConfigurationId: credentialRequest.credentialConfigurationId,
      proofs: credentialRequest.proofs,
      credentialResponseEncryption: CredentialResponseEncryptionDTO(
        jwk: responseJwk,
        enc: enc.rawValue
      )
    )

    let jwe = try jwtUtil.encryptJwe(
      payload: encryptedRequest,
      recipientKey: requestEncryption.key,
      enc: enc
    )

    let encryptedResponse = try await NetworkClient.fetchJwt(
      url,
      method: .post,
      contentType: "application/jwt",
      accept: "application/jwt",
      token: token,
      body: jwe.utf8Data
    )

    let response: CredentialResponse = try jwtUtil.decryptJwe(
      encryptedResponse,
      decryptionKey: ephemeralKey.jwkRepresentation
    )

    guard let credential = response.credentials.first else {
      throw AppError(reason: "Could not fetch credential")
    }

    return credential.credential
  }

  private func fetchPlainCredential(
    url: URL,
    token: String,
    credentialRequest: CredentialRequest
  ) async throws -> String {
    let response: CredentialResponse = try await NetworkClient.fetch(
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
    let response: NonceResponse = try await NetworkClient.fetch(
      url,
      method: .post
    )
    return response.cNonce
  }
}
