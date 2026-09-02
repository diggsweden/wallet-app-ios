// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CryptoKit
import Foundation
import Jose
import OpenId4VCInterface
import WalletNetworking

struct CredentialEndpointClient {
  private let encoder = JSONEncoder()

  func fetchCredential(
    url: URL,
    authorization: RequestAuthorization,
    credentialRequest: CredentialRequest,
    requestEncryption: CryptoSpec? = nil,
  ) async throws -> String {
    guard let requestEncryption else {
      return try await fetchPlainCredential(
        url: url,
        authorization: authorization,
        credentialRequest: credentialRequest,
      )
    }

    let ephemeralKey = P256.KeyAgreement.PrivateKey()
    let enc = requestEncryption.enc

    var responseJwk = WalletJoseJWK(ephemeralKey.publicKey)
    responseJwk.algorithm = WalletJoseKeyManagementAlgorithm.ecdhES.rawValue

    let encryptedRequest = CredentialRequest(
      credentialConfigurationId: credentialRequest.credentialConfigurationId,
      proofs: credentialRequest.proofs,
      credentialResponseEncryption: CredentialResponseEncryptionDTO(
        jwk: responseJwk,
        enc: enc.rawValue,
      ),
    )

    let jwe = try JwtUtil.encryptJwe(
      payload: encryptedRequest,
      recipientKey: requestEncryption.key,
      enc: enc,
    )

    let encryptedResponse = try await NetworkClient.fetchJwt(
      url,
      method: .post,
      contentType: "application/jwt",
      accept: "application/jwt",
      authorization: authorization,
      body: Data(jwe.utf8),
    )

    let response: CredentialResponse = try JwtUtil.decryptJwe(
      encryptedResponse,
      decryptionKey: WalletJoseJWK(ephemeralKey),
    )

    guard let credential = response.credentials.first else {
      throw IssuanceError.invalidCredential
    }

    return credential.credential
  }

  private func fetchPlainCredential(
    url: URL,
    authorization: RequestAuthorization,
    credentialRequest: CredentialRequest,
  ) async throws -> String {
    let response: CredentialResponse = try await NetworkClient.fetch(
      url,
      method: .post,
      authorization: authorization,
      body: try encoder.encode(credentialRequest),
    )
    guard let credential = response.credentials.first else {
      throw IssuanceError.invalidCredential
    }

    return credential.credential
  }

  func fetchNonce(url: URL) async throws -> String {
    let response: NonceResponse = try await NetworkClient.fetch(url, method: .post)
    return response.cNonce
  }
}
