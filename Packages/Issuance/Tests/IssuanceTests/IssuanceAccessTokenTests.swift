// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import OpenID4VCI
import Testing
import WalletNetworkingTestSupport

@testable import Issuance

struct IssuanceAccessTokenTests {
  @Test func `a DPoP token is sent with a proof`() throws {
    let token = try IssuanceAccessToken(accessToken: "t", tokenType: .dpop)

    guard
      case .dpop(let accessToken, _) = token.requestAuthorization(
        proofBuilder: FakeDpopProofProvider()
      )
    else {
      Issue.record("expected dpop authorization")
      return
    }
    #expect(accessToken == "t")
  }

  @Test(arguments: [TokenType.bearer, nil])
  func `a bearer or untyped token is sent as a plain bearer`(tokenType: TokenType?) throws {
    let token = try IssuanceAccessToken(accessToken: "t", tokenType: tokenType)

    guard
      case .bearer(let accessToken) = token.requestAuthorization(
        proofBuilder: FakeDpopProofProvider()
      )
    else {
      Issue.record("expected bearer authorization")
      return
    }
    #expect(accessToken == "t")
  }
}
