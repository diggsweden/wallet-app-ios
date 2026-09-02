// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Testing

@testable import Presentation

struct RequestBodyTests {
  @Test func `encodes state, nonce and vp_token with reserved characters percent-encoded`() throws {
    let vpToken = VerifiablePresentationToken(
      state: "state-1",
      nonce: "nonce-1",
      vpToken: ["cred1": ["a+b&c=d"]],
    )

    let body = try PresentationSession.createRequestBody(with: vpToken)

    #expect(
      body == "state=state-1&nonce=nonce-1&vp_token=%7B%22cred1%22:%5B%22a%2Bb%26c%3Dd%22%5D%7D"
    )
  }

  @Test func `omits state when the request has none`() throws {
    let vpToken = VerifiablePresentationToken(state: nil, nonce: "nonce-1", vpToken: [:])

    let body = try PresentationSession.createRequestBody(with: vpToken)

    #expect(body == "nonce=nonce-1&vp_token=%7B%7D")
  }
}
