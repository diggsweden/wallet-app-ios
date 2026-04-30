// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

public final actor SessionManager {
  private var token: String?
  private let signingProvider: any SessionSigningProvider
  private let accountIdProvider: any AccountIdProvider
  let client: Client

  public init(
    signingProvider: any SessionSigningProvider,
    accountIdProvider: any AccountIdProvider,
    baseUrl: URL
  ) {
    self.signingProvider = signingProvider
    self.accountIdProvider = accountIdProvider
    client = Client(
      serverURL: baseUrl,
      transport: URLSessionTransport()
    )
  }

  public func getToken() async throws -> String {
    if let token {
      return token
    }
    return try await initSession()
  }

  public func reset() {
    token = nil
  }

  private func initSession() async throws -> String {
    let keyId = try signingProvider.keyId()
    let nonce = try await getChallenge(keyId: keyId)
    let sessionToken = try await validateChallenge(keyId: keyId, nonce: nonce)
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

  private func validateChallenge(keyId: String, nonce: String) async throws -> String {
    let jwt = try signingProvider.signSessionJwt(keyId: keyId, nonce: nonce)
    let input = Operations.ValidateChallenge.Input(body: .json(.init(signedJwt: jwt)))
    let response = try await client.validateChallenge(input)

    guard case let .ok(payload) = response else {
      throw SessionError.failedChallenge
    }

    return try payload.body.json.sessionId
  }
}
