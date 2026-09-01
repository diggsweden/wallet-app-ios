// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Testing
import WalletMacros

@testable import WalletDemo

private let credentialEndpoint = #URL("https://issuer.example.com/credential")

@Suite("URLRequest construction")
struct NetworkRequestTests {
  private func makeRequest(
    method: HTTPMethod = .post,
    contentType: String? = "application/json",
    accept: String? = "application/json",
    authorization: RequestAuthorization? = nil,
    body: Data? = nil,
    dpopNonce: String? = nil,
  ) async throws -> URLRequest {
    try await NetworkRequest(
      url: credentialEndpoint,
      method: method,
      contentType: contentType,
      accept: accept,
      authorization: authorization,
      body: body,
    )
    .urlRequest(dpopNonce: dpopNonce)
  }

  @Test("the method, url and body are carried over")
  func carriesMethodUrlAndBody() async throws {
    let body = Data(#"{"hello":"world"}"#.utf8)
    let request = try await makeRequest(body: body)

    #expect(request.httpMethod == "POST")
    #expect(request.url == credentialEndpoint)
    #expect(request.httpBody == body)
  }

  @Test("content type and accept are sent when given")
  func sendsContentHeaders() async throws {
    let request = try await makeRequest(contentType: "application/jwt", accept: "application/jwt")

    #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/jwt")
    #expect(request.value(forHTTPHeaderField: "Accept") == "application/jwt")
  }

  @Test("headers that were not asked for are left off entirely")
  func omitsNilContentHeaders() async throws {
    let request = try await makeRequest(contentType: nil, accept: nil)

    #expect(request.value(forHTTPHeaderField: "Content-Type") == nil)
    #expect(request.value(forHTTPHeaderField: "Accept") == nil)
  }

  @Test("an unauthorized request carries no authorization headers")
  func unauthorizedRequest() async throws {
    let request = try await makeRequest(authorization: nil)

    #expect(request.value(forHTTPHeaderField: "Authorization") == nil)
    #expect(request.value(forHTTPHeaderField: "DPoP") == nil)
  }

  @Test("authorization headers are sent alongside the content headers")
  func mergesAuthorizationHeaders() async throws {
    let request = try await makeRequest(authorization: .bearer("access-token"))

    #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer access-token")
    #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
    #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
  }

  @Test("a dpop request carries both the token and its proof")
  func dpopRequest() async throws {
    let request = try await makeRequest(
      authorization: .dpop(accessToken: "access-token", proofBuilder: DpopProofBuilder()),
      dpopNonce: "nonce-abc",
    )

    #expect(request.value(forHTTPHeaderField: "Authorization") == "DPoP access-token")

    let proof = try DecodedJwt(compact: try #require(request.value(forHTTPHeaderField: "DPoP")))
    #expect(proof.claim("nonce") == "nonce-abc")
  }
}
