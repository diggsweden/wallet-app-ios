// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import JoseTestSupport
import Testing
import WalletMacros
import WalletNetworking

@testable import Jose

private let credentialEndpoint = #URL("https://issuer.example.com/credential?format=vc")

@Suite("Request authorization headers")
struct RequestAuthorizationTests {
  private let proofBuilder = DpopProofBuilder()

  private func makeHeaders(
    _ authorization: RequestAuthorization,
    method: HTTPMethod = .post,
    dpopNonce: String? = nil,
  ) async throws -> [String: String] {
    try await authorization.headers(
      endpoint: credentialEndpoint,
      method: method,
      dpopNonce: dpopNonce,
    )
  }

  @Test("a bearer token is sent with the Bearer scheme and carries no proof")
  func bearerScheme() async throws {
    let headers = try await makeHeaders(.bearer("access-token"))

    #expect(headers["Authorization"] == "Bearer access-token")
    #expect(headers["DPoP"] == nil)
  }

  @Test("a dpop token is sent with the DPoP scheme and a proof bound to the request")
  func dpopScheme() async throws {
    let headers = try await makeHeaders(
      .dpop(accessToken: "access-token", proofBuilder: proofBuilder)
    )

    #expect(headers["Authorization"] == "DPoP access-token")

    let proof = try DecodedJwt(compact: try #require(headers["DPoP"]))
    #expect(proof.claim("htm") == "POST")
    #expect(proof.claim("htu") == "https://issuer.example.com/credential")
    #expect(proof.claim("nonce") == nil)
  }

  @Test("the challenge nonce is bound into the proof of the retried request")
  func retriedProofCarriesNonce() async throws {
    let headers = try await makeHeaders(
      .dpop(accessToken: "access-token", proofBuilder: proofBuilder),
      dpopNonce: "nonce-abc",
    )

    let proof = try DecodedJwt(compact: try #require(headers["DPoP"]))
    #expect(proof.claim("nonce") == "nonce-abc")
  }

  @Test("the retried proof is a fresh proof of the same token")
  func retriedProofIsFresh() async throws {
    let authorization = RequestAuthorization.dpop(
      accessToken: "access-token",
      proofBuilder: proofBuilder,
    )

    let first = try DecodedJwt(compact: try #require(await makeHeaders(authorization)["DPoP"]))
    let second = try DecodedJwt(
      compact: try #require(await makeHeaders(authorization, dpopNonce: "nonce-abc")["DPoP"])
    )

    #expect(first.claim("jti") != second.claim("jti"))
    #expect(first.claim("ath") == second.claim("ath"))
  }

  @Test("the proof is bound to the method of the request it accompanies")
  func proofBindsMethod() async throws {
    let headers = try await makeHeaders(
      .dpop(accessToken: "access-token", proofBuilder: proofBuilder),
      method: .get,
    )

    let proof = try DecodedJwt(compact: try #require(headers["DPoP"]))
    #expect(proof.claim("htm") == "GET")
  }
}
