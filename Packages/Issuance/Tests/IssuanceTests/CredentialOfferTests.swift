// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfacesTestSupport
import OpenID4VCI
import OpenId4VCInterface
import Testing

@testable import Issuance

struct SdJwtVcConfigurationTests {
  @Test func `selects the first offered configuration`() throws {
    let (id, configuration) =
      try Fixtures.offer(
        configurationIds: [Fixtures.sdJwtConfigurationId, Fixtures.mdocConfigurationId]
      )
      .sdJwtVcConfiguration()

    #expect(id.value == Fixtures.sdJwtConfigurationId)
    #expect(configuration.vct == SampleCredential.pidType)
  }

  @Test func `an offer whose first configuration is not SD-JWT VC is unsupported`() throws {
    let offer = try Fixtures.offer(
      configurationIds: [Fixtures.mdocConfigurationId, Fixtures.sdJwtConfigurationId]
    )

    #expect(throws: IssuanceError.credentialNotSupported) {
      try offer.sdJwtVcConfiguration()
    }
  }

  @Test func `an offer for a configuration the issuer does not advertise is unsupported`() throws {
    let offer = try Fixtures.offer(configurationIds: ["unknown"])

    #expect(throws: IssuanceError.credentialNotSupported) {
      try offer.sdJwtVcConfiguration()
    }
  }
}
