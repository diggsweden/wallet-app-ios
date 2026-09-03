// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CryptoKit
import Foundation
import Jose
import JoseTestSupport
import OpenId4VCInterfaceTestSupport
import Testing

@testable import Issuance

struct ProofTests {
  private let issuerId = "https://issuer.example"

  @Test func `without key attestation the header advertises the signer key as jwk`() async throws {
    let signer = FakeProofSigner()

    let proof = try await IssuanceSession.buildProof(
      issuerId: issuerId,
      nonce: "nonce-1",
      keyAttestation: nil,
      signer: signer,
    )
    let decoded = try DecodedJwt(compact: proof)
    let jwk = try #require(decoded.jwk)

    #expect(decoded.header["alg"] as? String == "ES256")
    #expect(decoded.header["typ"] as? String == "openid4vci-proof+jwt")
    #expect(decoded.header["kid"] == nil)
    #expect(decoded.header["key_attestation"] == nil)
    #expect(jwk["kty"] as? String == "EC")
    #expect(jwk["crv"] as? String == "P-256")
    #expect(jwk["x"] as? String == WalletJoseJWK(signer.key.publicKey).x?.base64UrlEncodedString())
    #expect(jwk["y"] as? String == WalletJoseJWK(signer.key.publicKey).y?.base64UrlEncodedString())
  }

  @Test func `with key attestation the header names attested key 0 and omits jwk`() async throws {
    let proof = try await IssuanceSession.buildProof(
      issuerId: issuerId,
      nonce: "nonce-1",
      keyAttestation: "attestation-jwt",
      signer: FakeProofSigner(),
    )
    let decoded = try DecodedJwt(compact: proof)

    #expect(decoded.header["kid"] as? String == "0")
    #expect(decoded.header["key_attestation"] as? String == "attestation-jwt")
    #expect(decoded.jwk == nil)
  }

  @Test func `claims carry the issuer as aud, the nonce and the wallet client id`() async throws {
    let proof = try await IssuanceSession.buildProof(
      issuerId: issuerId,
      nonce: "nonce-1",
      keyAttestation: nil,
      signer: FakeProofSigner(),
    )
    let decoded = try DecodedJwt(compact: proof)

    #expect(decoded.claims["aud"] as? String == issuerId)
    #expect(decoded.claims["nonce"] as? String == "nonce-1")
    #expect(decoded.claims["iss"] as? String == "wallet-app")
    #expect(decoded.claims["iat"] is Int)
    #expect(decoded.claims["exp"] is Int)
  }

  @Test func `omits the nonce claim when the issuer has no nonce endpoint`() async throws {
    let proof = try await IssuanceSession.buildProof(
      issuerId: issuerId,
      nonce: nil,
      keyAttestation: nil,
      signer: FakeProofSigner(),
    )
    let decoded = try DecodedJwt(compact: proof)

    #expect(decoded.claims["nonce"] == nil)
  }

  @Test func `signature verifies with the key advertised in the header`() async throws {
    let proof = try await IssuanceSession.buildProof(
      issuerId: issuerId,
      nonce: "nonce-1",
      keyAttestation: nil,
      signer: FakeProofSigner(),
    )
    let decoded = try DecodedJwt(compact: proof)

    #expect(try decoded.verifiesWithAdvertisedKey())
  }
}
