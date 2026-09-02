// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfacesTestSupport
import Testing
import eudi_lib_sdjwt_swift

@testable import Presentation

struct DcqlMappingTests {
  private func queries(
    credentials: String,
    credentialSets: String? = nil,
  ) throws -> [CredentialQuery] {
    OpenId4VpRequestResolver.credentialQueries(
      from: try Fixtures.dcql(credentials: credentials, credentialSets: credentialSets)
    )
  }

  @Test func `reads the id, vct values and claim paths in request order`() throws {
    let mapped = try queries(
      credentials:
        "[\(Fixtures.pidCredential(id: "first")), \(Fixtures.pidCredential(id: "second"))]"
    )

    #expect(mapped.map(\.id) == ["first", "second"])
    #expect(mapped[0].vctValues == [SampleCredential.pidType])
    #expect(mapped[0].claimPaths == [ClaimPath([.claim(name: "given_name")])])
  }

  @Test func `maps nested, indexed and wildcard path elements`() throws {
    let claims =
      #"[{"path": ["address", "street_address"]}, "#
      + #"{"path": ["nationalities", 0]}, "#
      + #"{"path": ["nationalities", null]}]"#

    let mapped = try queries(credentials: "[\(Fixtures.pidCredential(claims: claims))]")

    #expect(
      mapped[0].claimPaths == [
        ClaimPath([.claim(name: "address"), .claim(name: "street_address")]),
        ClaimPath([.claim(name: "nationalities"), .arrayElement(index: 0)]),
        ClaimPath([.claim(name: "nationalities"), .allArrayElements]),
      ]
    )
  }

  @Test func `a credential query without claims asks for no disclosures`() throws {
    let mapped = try queries(credentials: "[\(Fixtures.pidCredential(claims: nil))]")

    #expect(mapped[0].claimPaths.isEmpty)
  }

  @Test func `a credential query without vct_values has none to match on`() throws {
    let json =
      #"{"id": "pid", "format": "dc+sd-jwt", "meta": {}, "claims": [{"path": ["given_name"]}]}"#

    let mapped = try queries(credentials: "[\(json)]")

    #expect(mapped[0].vctValues.isEmpty)
  }

  @Test func `without credential_sets every credential is required`() throws {
    let mapped = try queries(credentials: "[\(Fixtures.pidCredential())]")

    #expect(mapped[0].required)
  }

  @Test func `a set whose required flag is omitted is required`() throws {
    let mapped = try queries(
      credentials: "[\(Fixtures.pidCredential())]",
      credentialSets: #"[{"options": [["pid"]]}]"#,
    )

    #expect(mapped[0].required)
  }

  @Test func `a credential only in an optional set is optional`() throws {
    let mapped = try queries(
      credentials: "[\(Fixtures.pidCredential())]",
      credentialSets: #"[{"options": [["pid"]], "required": false}]"#,
    )

    #expect(mapped[0].required == false)
  }

  @Test func `a credential in both a required and an optional set is required`() throws {
    let mapped = try queries(
      credentials: "[\(Fixtures.pidCredential())]",
      credentialSets: #"[{"options": [["pid"]], "required": false}, {"options": [["pid"]]}]"#,
    )

    #expect(mapped[0].required)
  }

  @Test func `with credential_sets present, a credential in no set is optional`() throws {
    let mapped = try queries(
      credentials: "[\(Fixtures.pidCredential(id: "pid")), \(Fixtures.pidCredential(id: "extra"))]",
      credentialSets: #"[{"options": [["pid"]]}]"#,
    )

    #expect(mapped.map(\.required) == [true, false])
  }
}
