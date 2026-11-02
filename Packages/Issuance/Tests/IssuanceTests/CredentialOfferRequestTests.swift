// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import OpenID4VCI
import OpenId4VCInterface
import Testing

@testable import Issuance

struct CredentialOfferRequestTests {
  @Test func `an offer uri with credential_offer is passed by value`() throws {
    let json = #"{"credential_issuer":"https://issuer.example"}"#
    var components = URLComponents(string: "openid-credential-offer://")!
    components.queryItems = [URLQueryItem(name: "credential_offer", value: json)]

    let request = try IssuanceSession.offerRequest(from: components.string!)

    guard case .passByValue(let value) = request else {
      Issue.record("Expected pass by value, got \(request)")
      return
    }

    #expect(value == json)
  }

  @Test func `an offer uri with credential_offer_uri is fetched by reference`() throws {
    let request = try IssuanceSession.offerRequest(
      from: "openid-credential-offer://?credential_offer_uri=https%3A%2F%2Fissuer.example%2Foffer"
    )

    guard case .fetchByReference(let url) = request else {
      Issue.record("Expected fetch by reference, got \(request)")
      return
    }

    #expect(url.absoluteString == "https://issuer.example/offer")
  }

  @Test(arguments: [
    "openid-credential-offer://",
    "openid-credential-offer://?credential_offer=",
    "openid-credential-offer://?credential_offer_uri=",
    "https://issuer.example/offers/123",
  ])
  func `an offer uri without offer parameters is rejected`(offerUri: String) {
    #expect(throws: IssuanceError.invalidOffer) {
      try IssuanceSession.offerRequest(from: offerUri)
    }
  }
}
