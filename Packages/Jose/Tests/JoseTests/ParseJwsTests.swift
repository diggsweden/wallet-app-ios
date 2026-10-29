// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Testing

@testable import Jose

struct ParseJwsTests {
  @Test func `rejects a JWS whose typ does not match the expected type`() {
    #expect(throws: JwsError.unexpectedType(expected: "rc-wrp+jwt", actual: "JWT")) {
      try parse(header: #"{"alg":"ES256","typ":"JWT"}"#)
    }
  }

  @Test func `rejects a JWS without typ when a type is expected`() {
    #expect(throws: JwsError.unexpectedType(expected: "rc-wrp+jwt", actual: nil)) {
      try parse(header: #"{"alg":"ES256"}"#)
    }
  }

  @Test(arguments: ["rc-wrp+jwt", "RC-WRP+JWT", "application/rc-wrp+jwt"])
  func `accepts typ regardless of case and application prefix`(type: String) {
    #expect(throws: JwsError.noCertificateChain) {
      try parse(header: #"{"alg":"ES256","typ":"\#(type)"}"#)
    }
  }

  private func parse(header: String) throws {
    let header = Data(header.utf8).base64UrlEncodedString()
    let payload = Data("{}".utf8).base64UrlEncodedString()
    let signature = Data("signature".utf8).base64UrlEncodedString()

    let _: [String: String] = try JwtUtil.parseJws(
      from: "\(header).\(payload).\(signature)",
      expectedType: .registrationCertificate,
      validateCertChain: { _ in throw JwsError.invalidCertificate },
    )
  }
}
