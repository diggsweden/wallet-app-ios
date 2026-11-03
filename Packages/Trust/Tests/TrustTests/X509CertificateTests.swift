// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Testing

@testable import Trust

struct X509CertificateTests {
  @Test func `a base64 der value is parsed`() throws {
    let certificate = try #require(X509Certificate(val: Fixtures.rootCertificate).secCertificate)

    #expect(Fixtures.der(certificate) == (try Fixtures.der(of: Fixtures.rootCertificate)))
  }

  //  @Test func `a pem value is parsed`() throws {
  //    let lines = stride(from: 0, to: Fixtures.rootCertificate.count, by: 64)
  //      .map {
  //        Fixtures.rootCertificate.dropFirst($0).prefix(64)
  //      }
  //    let pem = """
  //      -----BEGIN CERTIFICATE-----
  //      \(lines.joined(separator: "\n"))
  //      -----END CERTIFICATE-----
  //
  //      """
  //
  //    let certificate = try #require(X509Certificate(val: pem).secCertificate)
  //
  //    #expect(Fixtures.der(certificate) == (try Fixtures.der(of: Fixtures.rootCertificate)))
  //  }

  @Test func `an invalid value is rejected`() {
    #expect(X509Certificate(val: "not a certificate").secCertificate == nil)
  }
}
