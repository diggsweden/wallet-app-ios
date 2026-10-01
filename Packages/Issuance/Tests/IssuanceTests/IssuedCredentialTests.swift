// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfacesTestSupport
import OpenID4VCI
import OpenId4VCInterface
import Testing

@testable import Issuance

struct IssuedCredentialTests {
  @Test func `the saved credential is bound to the proof key it was issued for`() throws {
    let configuration = try Fixtures.offer().sdJwtVcConfiguration().configuration

    let issued = try OpenId4VCInterface.IssuedCredential(
      compactSdJwt: SampleCredential.compactSdJwt,
      configuration: configuration,
      issuer: nil,
      claimDisplayNames: ["given_name": "Förnamn"],
      keyId: "hsm-key-1",
    )

    #expect(issued.credential.keyId == "hsm-key-1")
    #expect(issued.credential.type == SampleCredential.pidType)
    #expect(issued.credential.compactSerialized == SampleCredential.compactSdJwt)
    #expect(issued.credential.claimsCount == issued.claims.count)
  }
}
