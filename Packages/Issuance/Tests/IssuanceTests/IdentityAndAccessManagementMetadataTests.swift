// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Testing

@testable import Issuance

struct IdentityAndAccessManagementMetadataTests {
  @Test func `an authorization server listing ES256 for DPoP supports it`() throws {
    #expect(try Fixtures.authorizationServerMetadata(dpop: true).supportsDpop)
  }

  @Test func `an authorization server without DPoP algorithms does not`() throws {
    #expect(try Fixtures.authorizationServerMetadata(dpop: false).supportsDpop == false)
  }
}
