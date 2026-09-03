// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import OpenId4VCInterface
import Testing
import WalletMacros
import WalletNetworkingTestSupport

@testable import Presentation

struct PresentationSessionTests {
  @Test func `resolving with no stored credential throws noCredential`() async {
    let session = PresentationSession(networkClient: FakeNetworkClient(body: ""))

    await #expect(throws: PresentationError.noCredential) {
      try await session.resolve(
        url: #URL("openid4vp://authorize?request_uri=https://verifier.example/request"),
        credentials: [],
      )
    }
  }
}
