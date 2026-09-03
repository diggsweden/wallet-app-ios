// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CryptoKit
import Foundation
import JoseTestSupport
import Testing
import WalletMacros
import WalletNetworking

@testable import Jose

private let credentialEndpoint = #URL("https://issuer.example.com/credential")

/// The same token, and so the same `ath`, as the Android suite uses.
private let accessToken = "some-access-token"
private let accessTokenHash = "CRLvO23C6lecaPrHhPjC3ZQu3FiSgIydavbmtHEV0SY"

@Suite("DPoP proof building")
struct DpopProofBuilderTests {
  private let builder = DpopProofBuilder()

  private func makeProof(
    endpoint: URL = credentialEndpoint,
    method: HTTPMethod = .post,
    accessToken: String? = accessToken,
    nonce: String? = nil,
  ) async throws -> DecodedJwt {
    let compact = try await builder.proof(
      endpoint: endpoint,
      method: method,
      accessToken: accessToken,
      nonce: nonce,
    )

    return try DecodedJwt(compact: compact)
  }

  @Test("header declares the dpop type and ES256")
  func headerType() async throws {
    let proof = try await makeProof()

    #expect(proof.headerString("typ") == "dpop+jwt")
    #expect(proof.headerString("alg") == "ES256")
  }

  @Test("header carries the public key and no private parameters")
  func headerJwkIsPublic() async throws {
    let jwk = try #require(await makeProof().jwk)

    #expect(jwk["kty"] as? String == "EC")
    #expect(jwk["crv"] as? String == "P-256")
    #expect(jwk["x"] != nil)
    #expect(jwk["y"] != nil)
    #expect(jwk["d"] == nil, "the private scalar must never be published")
  }

  @Test("the proof verifies with the key it advertises")
  func proofVerifies() async throws {
    let proof = try await makeProof()

    #expect(try proof.verifiesWithAdvertisedKey())
  }

  @Test("every proof gets a fresh jti")
  func freshJti() async throws {
    let first = try await makeProof()
    let second = try await makeProof()

    #expect(first.claim("jti") != nil)
    #expect(first.claim("jti") != second.claim("jti"))
  }

  @Test("htm is the uppercase request method")
  func htmIsMethod() async throws {
    let proof = try await makeProof(method: .get)

    #expect(proof.claim("htm") == "GET")
  }

  @Test("htu drops query and fragment")
  func htuDropsQueryAndFragment() async throws {
    let proof = try await makeProof(
      endpoint: #URL("https://issuer.example.com/credential?foo=bar#section")
    )

    #expect(proof.claim("htu") == "https://issuer.example.com/credential")
  }

  @Test("htu keeps a non-default port and the path")
  func htuKeepsPortAndPath() async throws {
    let proof = try await makeProof(
      endpoint: #URL("https://issuer.example.com:8443/pid-issuer/credential?x=1")
    )

    #expect(proof.claim("htu") == "https://issuer.example.com:8443/pid-issuer/credential")
  }

  @Test("htu leaves a url without query or fragment unchanged")
  func htuLeavesPlainUrlAlone() async throws {
    let proof = try await makeProof()

    #expect(proof.claim("htu") == "https://issuer.example.com/credential")
  }

  @Test("ath is the base64url sha256 of the access token")
  func athHashesToken() async throws {
    let proof = try await makeProof(accessToken: accessToken)

    #expect(proof.claim("ath") == accessTokenHash)
  }

  @Test("ath is absent when the request has no access token")
  func athAbsentWithoutToken() async throws {
    let proof = try await makeProof(accessToken: nil)

    #expect(proof.claim("ath") == nil)
  }

  @Test("nonce is present only when the server supplied one")
  func nonceOnlyWhenSupplied() async throws {
    let without = try await makeProof()
    let with = try await makeProof(nonce: "nonce-abc")

    #expect(without.claim("nonce") == nil)
    #expect(with.claim("nonce") == "nonce-abc")
  }

  @Test("iat is issued")
  func iatIsIssued() async throws {
    let proof = try await makeProof()
    let iat = try #require(proof.claims["iat"] as? Int)

    #expect(iat > 0)
  }
}
