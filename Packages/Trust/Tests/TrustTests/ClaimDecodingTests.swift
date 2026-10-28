// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import Foundation
import Testing

@testable import Trust

struct ClaimDecodingTests {
  @Test func `claim paths decode keys, indices and wildcards`() throws {
    let json = #"{"path": ["nationalities", 0, null]}"#

    let claim = try JSONDecoder().decode(Claim.self, from: Data(json.utf8))

    #expect(
      claim.path
        == ClaimPath([.claim(name: "nationalities"), .arrayElement(index: 0), .allArrayElements])
    )
  }
}
