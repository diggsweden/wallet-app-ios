// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Testing
import WalletMacros

@testable import WalletDemo

@Suite("DPoP nonce challenge detection")
struct HTTPErrorDpopNonceTests {
  private let url = #URL("https://issuer.example.com/credential")

  private func makeResponse(status: Int, headers: [String: String]) throws -> HTTPURLResponse {
    try #require(
      HTTPURLResponse(
        url: url,
        statusCode: status,
        httpVersion: "HTTP/1.1",
        headerFields: headers,
      )
    )
  }

  /// A challenge always names a nonce for the client to use, so it is added
  /// here; the tests that need it absent build their own response.
  private func makeError(
    status: Int,
    headers: [String: String] = [:],
    body: String? = nil,
  ) throws -> HTTPError {
    let response = try makeResponse(
      status: status,
      headers: headers.merging(["DPoP-Nonce": "nonce-abc"]) { current, _ in current },
    )

    return .http(response: response, body: body.map { Data($0.utf8) })
  }

  @Test("resource server challenges over WWW-Authenticate with no error body")
  func resourceServerChallenge() throws {
    let challenge = #"DPoP error="use_dpop_nonce", error_description="nonce needed""#
    let error = try makeError(status: 401, headers: ["WWW-Authenticate": challenge])

    #expect(error.dpopNonceChallenge == "nonce-abc")
  }

  @Test("authorization server challenges over the error body")
  func authorizationServerChallenge() throws {
    let error = try makeError(status: 400, body: #"{"error":"use_dpop_nonce"}"#)

    #expect(error.dpopNonceChallenge == "nonce-abc")
  }

  @Test("challenge is recognised across the 4xx range")
  func acceptsAny4xx() throws {
    let error = try makeError(status: 403, body: #"{"error":"use_dpop_nonce"}"#)

    #expect(error.dpopNonceChallenge == "nonce-abc")
  }

  @Test("header names are matched case-insensitively")
  func caseInsensitiveHeaders() throws {
    let response = try makeResponse(
      status: 401,
      headers: [
        "www-authenticate": #"dpop error="use_dpop_nonce""#,
        "dpop-nonce": "nonce-abc",
      ],
    )
    let error = HTTPError.http(response: response, body: nil)

    #expect(error.dpopNonceChallenge == "nonce-abc")
  }

  @Test("a different error code is a refusal, not a challenge")
  func otherErrorCode() throws {
    let error = try makeError(status: 400, body: #"{"error":"invalid_dpop_proof"}"#)

    #expect(error.dpopNonceChallenge == nil)
  }

  @Test("a WWW-Authenticate naming another error is not a challenge")
  func otherErrorInHeader() throws {
    let error = try makeError(
      status: 401,
      headers: ["WWW-Authenticate": #"DPoP error="invalid_token""#],
    )

    #expect(error.dpopNonceChallenge == nil)
  }

  @Test("a server fault is not a challenge, even when it names the error code")
  func serverError() throws {
    let error = try makeError(status: 503, body: #"{"error":"use_dpop_nonce"}"#)

    #expect(error.dpopNonceChallenge == nil)
  }

  @Test("a body that is not an error response is not a challenge")
  func nonJsonBody() throws {
    let error = try makeError(status: 400, body: "not json at all")

    #expect(error.dpopNonceChallenge == nil)
  }

  @Test("a successful response is never a challenge")
  func successfulResponse() throws {
    let error = try makeError(status: 200, body: #"{"error":"use_dpop_nonce"}"#)

    #expect(error.dpopNonceChallenge == nil)
  }

  @Test("a challenge without a nonce to use is not actionable")
  func missingNonceHeader() throws {
    let response = try makeResponse(
      status: 401,
      headers: ["WWW-Authenticate": #"DPoP error="use_dpop_nonce""#],
    )
    let error = HTTPError.http(response: response, body: nil)

    #expect(error.dpopNonceChallenge == nil)
  }

  @Test("a non-http error is never a challenge")
  func nonHttpError() {
    let error = HTTPError.transport(underlying: URLError(.timedOut), url: url)

    #expect(error.dpopNonceChallenge == nil)
  }
}
