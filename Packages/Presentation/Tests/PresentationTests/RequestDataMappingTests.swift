// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import OpenID4VP
import OpenId4VCInterface
import Testing

@testable import Presentation

struct RequestDataMappingTests {
  private func vpTokenData(state: String? = "state-1") throws -> ResolvedRequestData.VpTokenData {
    let dcql = try Fixtures.dcql(credentials: "[\(Fixtures.pidCredential(claims: nil))]")

    return try ResolvedRequestData.VpTokenData(
      presentationQuery: .byDigitalCredentialsQuery(dcql),
      clientMetaData: nil,
      client: .preRegistered(clientId: "verifier-1", legalName: "Verifier"),
      nonce: "nonce-1",
      responseMode: .directPost(responseURI: Fixtures.responseUrl),
      state: state,
      vpFormatsSupported: VpFormatsSupported(),
      responseEncryptionSpecification: nil,
    )
  }

  @Test func `a direct_post request is kept with its response url, client, nonce and state`()
    throws
  {
    let data = try OpenId4VpRequestResolver.requestData(from: vpTokenData())

    #expect(data.responseUrl == Fixtures.responseUrl)
    #expect(data.clientId == "verifier-1")
    #expect(data.nonce == "nonce-1")
    #expect(data.state == "state-1")
    #expect(data.credentialQueries.map(\.id) == ["pid"])
  }

  @Test func `a request without state is kept without one`() throws {
    let data = try OpenId4VpRequestResolver.requestData(from: vpTokenData(state: nil))

    #expect(data.state == nil)
  }
}
