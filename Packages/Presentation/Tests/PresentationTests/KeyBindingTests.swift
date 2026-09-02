// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfacesTestSupport
import CryptoKit
import Foundation
import Jose
import JoseTestSupport
import OpenId4VCInterface
import OpenId4VCInterfaceTestSupport
import Testing

@testable import Presentation

struct KeyBindingTests {
  @Test func `header has ES256 and kb+jwt, claims have aud, nonce, iat and exp`() async throws {
    let signer = FakeProofSigner()
    let sdJwt = SampleCredential.compactSdJwt

    let jwt = try await PresentationSession.createKeyBinding(
      for: sdJwt,
      aud: "https://verifier.example",
      nonce: "nonce-1",
      signer: signer,
    )
    let decoded = try DecodedJwt(compact: jwt)

    #expect(decoded.header["alg"] as? String == "ES256")
    #expect(decoded.header["typ"] as? String == "kb+jwt")
    #expect(decoded.claims["aud"] as? String == "https://verifier.example")
    #expect(decoded.claims["nonce"] as? String == "nonce-1")
    #expect(decoded.claims["iat"] is Int)
    #expect(decoded.claims["exp"] is Int)
  }

  @Test func `sd_hash is the base64url SHA-256 of the presented SD-JWT`() async throws {
    let sdJwt = SampleCredential.compactSdJwt
    let expected = Data(SHA256.hash(data: Data(sdJwt.utf8))).base64UrlEncodedString()

    let jwt = try await PresentationSession.createKeyBinding(
      for: sdJwt,
      aud: "aud",
      nonce: "nonce",
      signer: FakeProofSigner(),
    )
    let decoded = try DecodedJwt(compact: jwt)

    #expect(decoded.claims["sd_hash"] as? String == expected)
  }

  @Test func `signature covers the header and claims`() async throws {
    let signer = FakeProofSigner()

    let jwt = try await PresentationSession.createKeyBinding(
      for: SampleCredential.compactSdJwt,
      aud: "aud",
      nonce: "nonce",
      signer: signer,
    )
    let decoded = try DecodedJwt(compact: jwt)

    #expect(try decoded.verifies(with: signer.key.publicKey))
    #expect(decoded.jwk == nil, "the key is bound through cnf, never advertised in the KB-JWT")
  }

  @Test func `rejects an SD-JWT that is not ASCII`() async {
    await #expect(throws: PresentationError.keyBindingEncodingFailed) {
      try await PresentationSession.createKeyBinding(
        for: "não-ascii",
        aud: "aud",
        nonce: "nonce",
        signer: FakeProofSigner(),
      )
    }
  }
}
