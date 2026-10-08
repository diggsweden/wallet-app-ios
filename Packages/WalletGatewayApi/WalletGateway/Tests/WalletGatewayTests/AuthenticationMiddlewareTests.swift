// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import HTTPTypes
import Testing
import WalletGatewayInterface

@testable import WalletGateway

@Suite("AuthenticationMiddleware")
struct AuthenticationMiddlewareTests {
  @Test(
    "Sessionless operations are sent with the API key and no session",
    arguments: [Operations.CreateAccount.id, Operations.GetClientConfig.id],
  )
  func sessionlessOperation(operationID: String) async throws {
    let accountIds = CountingAccountIdProvider()
    var forwarded: HTTPRequest?

    _ = try await makeMiddleware(accountIdProvider: accountIds).intercept(
      makeRequest(),
      body: nil,
      baseURL: baseURL,
      operationID: operationID,
    ) { request, body, _ in
      forwarded = request
      return (HTTPResponse(status: .ok), body)
    }

    let request = try #require(forwarded)
    #expect(request.headerFields[try #require(HTTPField.Name("X-API-KEY"))] == "api-key")
    #expect(request.headerFields[try #require(HTTPField.Name("session"))] == nil)
    #expect(await accountIds.calls == 0)
  }

  @Test("Other operations need a session before the request is sent")
  func sessionOperation() async throws {
    let accountIds = CountingAccountIdProvider()
    var forwarded = false

    do {
      _ = try await makeMiddleware(accountIdProvider: accountIds).intercept(
        makeRequest(),
        body: nil,
        baseURL: baseURL,
        operationID: Operations.GetApiInfo.id,
      ) { _, body, _ in
        forwarded = true
        return (HTTPResponse(status: .ok), body)
      }
      Issue.record("Expected the session manager to reject a missing account")
    } catch SessionError.noAccountId {}

    #expect(!forwarded)
    #expect(await accountIds.calls == 1)
  }
}

private let baseURL = URL(string: "https://gateway.example")!

private func makeRequest() -> HTTPRequest {
  HTTPRequest(method: .get, scheme: "https", authority: "gateway.example", path: "/")
}

private func makeMiddleware(
  accountIdProvider: CountingAccountIdProvider
) -> AuthenticationMiddleware {
  AuthenticationMiddleware(
    sessionManager: SessionManager(
      signingProvider: UnusedSessionSigner(),
      accountIdProvider: accountIdProvider,
      baseUrl: baseURL,
      deviceInfo: DeviceInfo(os: "iOS", osVersion: "26.0", model: "iPhone", appVersion: "1.0"),
    ),
    apiKey: "api-key",
  )
}

private actor CountingAccountIdProvider: AccountIdProvider {
  private(set) var calls = 0

  func accountId() -> String? {
    calls += 1
    return nil
  }
}

private struct UnusedSessionSigner: SessionSigningProvider {
  func keyId() throws -> String {
    throw SessionError.noKeyId
  }

  func signSessionJwt(keyId: String, nonce: String) throws -> String {
    throw SessionError.noKeyId
  }
}
