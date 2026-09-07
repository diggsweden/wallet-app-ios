// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CryptoKit
import Foundation
import Jose
import OpenID4VP
import OpenId4VCInterface
import Testing

@testable import Presentation

struct RequestDataMappingTests {
  private func vpTokenData(
    state: String? = "state-1",
    responseMode: ResponseMode = .directPost(responseURI: Fixtures.responseUrl),
    encryption: ResponseEncryptionSpecification? = nil,
  ) throws -> ResolvedRequestData.VpTokenData {
    let dcql = try Fixtures.dcql(credentials: "[\(Fixtures.pidCredential(claims: nil))]")

    return try ResolvedRequestData.VpTokenData(
      presentationQuery: .byDigitalCredentialsQuery(dcql),
      clientMetaData: nil,
      client: .preRegistered(clientId: "verifier-1", legalName: "Verifier"),
      nonce: "nonce-1",
      responseMode: responseMode,
      state: state,
      vpFormatsSupported: VpFormatsSupported(),
      responseEncryptionSpecification: encryption,
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
    #expect(data.encryption == nil)
    #expect(data.credentialQueries.map(\.id) == ["pid"])
  }

  @Test func `a request without state is kept without one`() throws {
    let data = try OpenId4VpRequestResolver.requestData(from: vpTokenData(state: nil))

    #expect(data.state == nil)
  }

  @Test func `direct_post jwt preserves the verifier key and encryption settings`() throws {
    var jwk = WalletJoseJWK(P256.KeyAgreement.PrivateKey().publicKey)
    jwk.keyID = "verifier-key"
    jwk.algorithm = "ECDH-ES"
    let key = try JSONDecoder().decode(WebKeySet.Key.self, from: JSONEncoder().encode(jwk))
    let specification = ResponseEncryptionSpecification(
      responseEncryptionAlg: .init(.ECDH_ES),
      responseEncryptionEnc: .init(.A128GCM),
      clientKey: WebKeySet(keys: [key]),
    )

    let data = try OpenId4VpRequestResolver.requestData(
      from: vpTokenData(
        responseMode: .directPostJWT(responseURI: Fixtures.responseUrl),
        encryption: specification,
      )
    )

    let encryption = try #require(data.encryption)
    #expect(data.responseUrl == Fixtures.responseUrl)
    #expect(encryption.alg == .ecdhES)
    #expect(encryption.enc == .a128GCM)
    #expect(encryption.key.keyID == jwk.keyID)
    #expect(encryption.key.x == jwk.x)
    #expect(encryption.key.y == jwk.y)
  }
}
