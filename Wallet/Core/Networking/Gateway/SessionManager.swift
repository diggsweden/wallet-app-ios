// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import HTTPTypes
import JSONWebSignature
import OpenAPIRuntime
import OpenAPIURLSession
import WalletMacros

final actor SessionManager {
  private var token: String? = nil
  private var expirationDate: Date = .now
  let client: Client
  let accountIdProvider: AccountIdProvider

  init(baseUrl: URL? = nil, accountIdProvider: AccountIdProvider) {
    let url = baseUrl ?? AppConfig.apiBaseUrl
    client = Client(
      serverURL: url,
      transport: URLSessionTransport(),
    )
    self.accountIdProvider = accountIdProvider
  }

  func getToken() async throws -> String {
    return if let token {
      token
    } else {
      try await initSession()
    }
  }

  func reset() {
    token = nil
  }

  private func initSession() async throws -> String {
    let key = try KeychainService.getOrCreateKey(withTag: .walletKey)

    guard let keyId = try? key.jwk.thumbprint() else {
      throw SessionError.noKeyId
    }

    let nonce = try await getChallenge(keyId: keyId)
    let sessionToken = try await validateChallenge(key: key, keyId: keyId, nonce: nonce)

    self.token = sessionToken
    return sessionToken
  }

  private func getChallenge(keyId: String) async throws -> String {
    guard let accountId = await accountIdProvider.accountId() else {
      throw SessionError.noAccountId
    }

    let query = Operations.InitChallenge.Input.Query(accountId: accountId, keyId: keyId)
    let response = try await client.initChallenge(query: query)

    guard
      case let .ok(payload) = response,
      let nonce = try? payload.body.json.nonce
    else {
      throw SessionError.failedChallenge
    }

    return nonce
  }

  private func validateChallenge(key: SecKey, keyId: String, nonce: String) async throws -> String {
    struct SessionPayload: Codable {
      let nonce: String
    }

    let header = DefaultJWSHeaderImpl(algorithm: .ES256, keyID: keyId)
    let payload = SessionPayload(nonce: nonce)
    let jwt = try JwtUtil().signJwt(with: key, payload: payload, header: header)
    let input = Operations.ValidateChallenge.Input(body: .json(.init(signedJwt: jwt)))
    let response = try await client.validateChallenge(input)

    guard case let .ok(payload) = response else {
      throw SessionError.failedChallenge
    }

    return try payload.body.json.sessionId
  }
}
