// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import OpenId4VCInterface
import Testing
import eudi_lib_sdjwt_swift

@testable import Presentation

struct CandidateMatchingTests {
  private let responseUrl = "https://verifier.example/response"

  private func query(
    id: String,
    claims: [String] = ["given_name"],
    required: Bool = true,
    vctValues: [String] = [Fixtures.pidType],
  ) -> CredentialQuery {
    CredentialQuery(
      id: id,
      claimPaths: Set(claims.map { ClaimPath([.claim(name: $0)]) }),
      required: required,
      vctValues: vctValues,
    )
  }

  private func request(
    _ queries: [CredentialQuery],
    state: String? = "state-1",
  ) throws -> PresentationRequestData {
    PresentationRequestData(
      credentialQueries: queries,
      responseUrl: try #require(URL(string: responseUrl)),
      clientId: "client-1",
      nonce: "nonce-1",
      state: state,
    )
  }

  @Test func `matches the credential by vct and discloses only the requested claims`() throws {
    let resolved = try PresentationSession.match(
      request([query(id: "pid")]),
      credentials: [Fixtures.credential()],
    )

    #expect(resolved.candidates.count == 1)
    #expect(resolved.candidates[0].id == "pid")
    #expect(resolved.candidates[0].claims.map(\.id) == ["given_name"])
    #expect(resolved.candidates[0].claims[0].displayName == "Förnamn")

    let issuerJwt = String(Fixtures.compactSdJwt.prefix { $0 != "~" })
    #expect(resolved.disclosedSdJwts["pid"]?.hasPrefix(issuerJwt) == true)
  }

  @Test func `picks the credential whose type is listed in vct_values`() throws {
    let other = Fixtures.credential(type: "urn:other", claimDisplayNames: ["given_name": "Other"])
    let pid = Fixtures.credential(claimDisplayNames: ["given_name": "Pid"])

    let resolved = try PresentationSession.match(
      request([query(id: "pid")]),
      credentials: [other, pid],
    )

    #expect(resolved.candidates[0].claims[0].displayName == "Pid")
  }

  @Test func `propagates the required flag per query, in query order`() throws {
    let resolved = try PresentationSession.match(
      request([query(id: "must", required: true), query(id: "may", required: false)]),
      credentials: [Fixtures.credential()],
    )

    #expect(resolved.candidates.map(\.id) == ["must", "may"])
    #expect(resolved.candidates.map(\.required) == [true, false])
  }

  @Test func `carries the request data into the resolved presentation`() throws {
    let resolved = try PresentationSession.match(
      request([query(id: "pid")]),
      credentials: [Fixtures.credential()],
    )

    #expect(resolved.responseUrl.absoluteString == responseUrl)
    #expect(resolved.clientId == "client-1")
    #expect(resolved.nonce == "nonce-1")
    #expect(resolved.state == "state-1")
  }

  @Test func `throws when no credential matches the requested vct`() throws {
    let data = try request([query(id: "pid", vctValues: ["urn:missing"])])

    #expect(throws: PresentationError.self) {
      try PresentationSession.match(data, credentials: [Fixtures.credential()])
    }
  }
}
