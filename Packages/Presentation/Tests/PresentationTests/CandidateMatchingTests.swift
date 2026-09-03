// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfacesTestSupport
import OpenId4VCInterface
import Testing
import eudi_lib_sdjwt_swift

@testable import Presentation

struct CandidateMatchingTests {
  @Test func `matches the credential by vct and discloses only the requested claims`() throws {
    let resolved = try PresentationSession.match(
      Fixtures.request([Fixtures.query(id: "pid")]),
      credentials: [SampleCredential.saved()],
    )

    #expect(resolved.candidates.count == 1)
    #expect(resolved.candidates[0].id == "pid")
    #expect(resolved.candidates[0].claims.map(\.id) == ["given_name"])
    #expect(resolved.candidates[0].claims[0].displayName == "Förnamn")

    #expect(resolved.disclosedSdJwts["pid"]?.hasPrefix(SampleCredential.issuerJwt) == true)
  }

  @Test func `the disclosed SD-JWT carries only the requested disclosures`() throws {
    let resolved = try PresentationSession.match(
      Fixtures.request([Fixtures.query(id: "pid", claims: ["given_name", "birthdate"])]),
      credentials: [SampleCredential.saved()],
    )

    let disclosed = try #require(resolved.disclosedSdJwts["pid"])
    let disclosures = disclosed.split(separator: "~", omittingEmptySubsequences: false).dropFirst()
    #expect(disclosed.hasSuffix("~"))
    #expect(disclosures.filter { !$0.isEmpty }.count == 2)
    #expect(resolved.candidates[0].claims.map(\.id) == ["birthdate", "given_name"])
  }

  @Test func `nested claims can be requested by path`() throws {
    let resolved = try PresentationSession.match(
      Fixtures.request([
        CredentialQuery(
          id: "pid",
          claimPaths: [ClaimPath([.claim(name: "address"), .claim(name: "street_address")])],
          required: true,
          vctValues: [SampleCredential.pidType],
        )
      ]),
      credentials: [SampleCredential.saved()],
    )

    #expect(resolved.candidates[0].claims.map(\.id) == ["address"])
  }

  @Test func `picks the credential whose type is listed in vct_values`() throws {
    let other = SampleCredential.saved(
      type: "urn:other",
      claimDisplayNames: ["given_name": "Other"],
    )
    let pid = SampleCredential.saved(claimDisplayNames: ["given_name": "Pid"])

    let resolved = try PresentationSession.match(
      Fixtures.request([Fixtures.query(id: "pid")]),
      credentials: [other, pid],
    )

    #expect(resolved.candidates[0].claims[0].displayName == "Pid")
  }

  @Test func `propagates the required flag per query, in query order`() throws {
    let resolved = try PresentationSession.match(
      Fixtures.request([
        Fixtures.query(id: "must", required: true), Fixtures.query(id: "may", required: false),
      ]),
      credentials: [SampleCredential.saved()],
    )

    #expect(resolved.candidates.map(\.id) == ["must", "may"])
    #expect(resolved.candidates.map(\.required) == [true, false])
  }

  @Test func `carries the request data into the resolved presentation`() throws {
    let resolved = try PresentationSession.match(
      Fixtures.request([Fixtures.query(id: "pid")]),
      credentials: [SampleCredential.saved()],
    )

    #expect(resolved.responseUrl == Fixtures.responseUrl)
    #expect(resolved.clientId == "verifier-1")
    #expect(resolved.nonce == "nonce-1")
    #expect(resolved.state == "state-1")
  }

  @Test func `throws when no credential matches the requested vct`() throws {
    let data = Fixtures.request([Fixtures.query(id: "pid", vctValues: ["urn:missing"])])

    #expect(throws: PresentationError.noMatchingCredential) {
      try PresentationSession.match(data, credentials: [SampleCredential.saved()])
    }
  }

  @Test func `one unmatched query fails the whole request even if others match`() throws {
    let data = Fixtures.request([
      Fixtures.query(id: "pid"), Fixtures.query(id: "other", vctValues: ["urn:missing"]),
    ])

    #expect(throws: PresentationError.noMatchingCredential) {
      try PresentationSession.match(data, credentials: [SampleCredential.saved()])
    }
  }

  @Test func `a query without vct_values can never match`() throws {
    let data = Fixtures.request([Fixtures.query(id: "pid", vctValues: [])])

    #expect(throws: PresentationError.noMatchingCredential) {
      try PresentationSession.match(data, credentials: [SampleCredential.saved()])
    }
  }

  // The SD-JWT library never reports a query it cannot satisfy, so today the
  // wallet offers the credential with nothing disclosed instead of failing.
  @Test func `a query for claims the credential lacks has no matching claims`() throws {
    let data = Fixtures.request([Fixtures.query(id: "pid", claims: ["passport_number"])])

    withKnownIssue("eudi-lib-sdjwt-swift silently drops unsatisfiable claim paths") {
      #expect(throws: PresentationError.noMatchingClaims) {
        try PresentationSession.match(data, credentials: [SampleCredential.saved()])
      }
    }
  }

  @Test func `two queries may resolve to the same stored credential`() throws {
    let resolved = try PresentationSession.match(
      Fixtures.request([
        Fixtures.query(id: "a", claims: ["given_name"]),
        Fixtures.query(id: "b", claims: ["family_name"]),
      ]),
      credentials: [SampleCredential.saved()],
    )

    #expect(resolved.candidates.map(\.id) == ["a", "b"])
    #expect(resolved.candidates[0].claims.map(\.id) == ["given_name"])
    #expect(resolved.candidates[1].claims.map(\.id) == ["family_name"])
    #expect(resolved.disclosedSdJwts["a"] != resolved.disclosedSdJwts["b"])
  }
}
