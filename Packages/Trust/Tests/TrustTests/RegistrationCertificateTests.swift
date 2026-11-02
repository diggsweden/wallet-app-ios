// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Testing

@testable import Trust

struct RegistrationCertificateTests {
  @Test(arguments: [(999, false), (1000, true), (1001, true)])
  func `certificate is expired on or after exp`(now: Int, expired: Bool) {
    let certificate = Fixtures.registrationCertificate(exp: 1000)

    #expect(certificate.isExpired(at: Date(timeIntervalSince1970: TimeInterval(now))) == expired)
  }
}
