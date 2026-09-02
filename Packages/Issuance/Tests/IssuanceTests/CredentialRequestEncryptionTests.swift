// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CryptoKit
import Jose
import Testing

@testable import Issuance

struct CredentialRequestEncryptionTests {
  private let issuerKey = P256.KeyAgreement.PrivateKey()

  private func spec(_ encryption: Fixtures.RequestEncryption?) throws -> CryptoSpec? {
    try Fixtures.issuerMetadata(requestEncryption: encryption)
      .credentialRequestEncryption
      .toCryptoSpec()
  }

  @Test func `required encryption yields the issuer key and method`() throws {
    let spec = try #require(try spec(.init(key: issuerKey.publicKey)))

    #expect(spec.enc == .a128GCM)
    #expect(spec.key.x == WalletJoseJWK(issuerKey.publicKey).x)
    #expect(spec.key.y == WalletJoseJWK(issuerKey.publicKey).y)
  }

  @Test func `optional encryption is not used`() throws {
    #expect(try spec(.init(key: issuerKey.publicKey, required: false)) == nil)
  }

  @Test func `an issuer without request encryption yields no spec`() throws {
    #expect(try spec(nil) == nil)
  }

  @Test func `an encryption method the wallet cannot produce yields no spec`() throws {
    #expect(try spec(.init(key: issuerKey.publicKey, method: "A128CBC")) == nil)
  }
}
