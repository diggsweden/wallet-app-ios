// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Testing

@testable import Trust

struct CertificateValidatorTests {
  @Test func `a chain issued by a trust anchor is valid`() throws {
    let leaf = try Fixtures.certificate(Fixtures.leafCertificate)
    let root = try Fixtures.certificate(Fixtures.rootCertificate)

    #expect(throws: Never.self) {
      try CertificateValidator.validate(certChain: [leaf], with: [root])
    }
  }

  @Test func `a chain not issued by any trust anchor throws`() throws {
    let leaf = try Fixtures.certificate(Fixtures.leafCertificate)
    let other = try Fixtures.certificate(Fixtures.otherCertificate)

    #expect(throws: (any Error).self) {
      try CertificateValidator.validate(certChain: [leaf], with: [other])
    }
  }
}
