// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import CredentialInterfacesTestSupport
import Testing

@testable import SdJwt

struct SelectiveDisclosureTests {
  private func disclose(
    _ paths: Set<ClaimPath>,
    displayNames: [String: String] = [:],
  ) throws -> DisclosedSdJwt? {
    try SdJwtVc.disclose(
      compactSerialized: SampleCredential.compactSdJwt,
      matching: paths,
      displayNames: displayNames,
    )
  }

  @Test func `keeps the issuer JWT and only the requested disclosures`() throws {
    let disclosed = try #require(
      try disclose([
        ClaimPath([.claim(name: "given_name")]),
        ClaimPath([.claim(name: "birthdate")]),
      ])
    )

    let serialized = disclosed.compactSerialized
    #expect(serialized.hasPrefix(SampleCredential.issuerJwt))
    #expect(serialized.hasSuffix("~"))

    let disclosures =
      serialized
      .split(separator: "~", omittingEmptySubsequences: false)
      .dropFirst()
      .filter { !$0.isEmpty }
    #expect(disclosures.count == 2)
    #expect(disclosed.claims.map(\.id) == ["birthdate", "given_name"])
  }

  @Test func `renders the disclosed claims with their display names`() throws {
    let disclosed = try #require(
      try disclose(
        [ClaimPath([.claim(name: "given_name")])],
        displayNames: ["given_name": "Förnamn"],
      )
    )

    #expect(disclosed.claims.map(\.displayName) == ["Förnamn"])
  }

  @Test func `a nested path discloses the parent claim`() throws {
    let disclosed = try #require(
      try disclose([ClaimPath([.claim(name: "address"), .claim(name: "street_address")])])
    )

    #expect(disclosed.claims.map(\.id) == ["address"])
  }

  @Test func `a path the credential lacks discloses nothing`() throws {
    let disclosed = try #require(try disclose([ClaimPath([.claim(name: "passport_number")])]))

    #expect(disclosed.claims.isEmpty)
  }
}
