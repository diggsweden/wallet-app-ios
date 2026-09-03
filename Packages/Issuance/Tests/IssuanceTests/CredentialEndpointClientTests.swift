// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CryptoKit
import Foundation
import Jose
import OpenId4VCInterface
import OpenId4VCInterfaceTestSupport
import Testing
import WalletMacros
import WalletNetworking
import WalletNetworkingTestSupport

@testable import Issuance

/// The issuer side of an encrypted exchange: decrypts the wallet's request and
/// answers with a response encrypted for the ephemeral key advertised in it.
private actor EncryptingIssuer {
  private let key = P256.KeyAgreement.PrivateKey()
  private(set) var receivedRequests: [CredentialRequest] = []

  var spec: CryptoSpec {
    CryptoSpec(key: WalletJoseJWK(key.publicKey), enc: .a128GCM)
  }

  func handle(_ sent: NetworkRequest) throws -> Data {
    let received: CredentialRequest = try JwtUtil.decryptJwe(
      try #require(sent.bodyText),
      decryptionKey: WalletJoseJWK(key),
    )
    receivedRequests.append(received)

    let response = try JwtUtil.encryptJwe(
      payload: CredentialResponse(credentials: [CredentialBody(credential: "issued-sd-jwt")]),
      recipientKey: try #require(received.credentialResponseEncryption).jwk,
      enc: .a128GCM,
    )
    return Data(response.utf8)
  }
}

struct CredentialEndpointClientTests {
  private let credentialUrl = #URL("https://issuer.example/credential")
  private let request = CredentialRequest(
    credentialConfigurationId: "pid",
    proofs: JwtProofType(jwt: ["proof-jwt"]),
  )

  private func credentialResponse(_ credentials: [String]) -> String {
    let list = credentials.map { #"{"credential": "\#($0)"}"# }.joined(separator: ",")
    return #"{"credentials": [\#(list)]}"#
  }

  private func fetchCredential(
    through network: FakeNetworkClient,
    requestEncryption: CryptoSpec? = nil,
  ) async throws -> String {
    try await CredentialEndpointClient(networkClient: network)
      .fetchCredential(
        url: credentialUrl,
        authorization: .bearer("token"),
        credentialRequest: request,
        requestEncryption: requestEncryption,
      )
  }

  @Test func `fetchNonce posts to the nonce endpoint and reads c_nonce`() async throws {
    let network = FakeNetworkClient(body: #"{"c_nonce": "nonce-1"}"#)
    let url = #URL("https://issuer.example/nonce")

    let nonce = try await CredentialEndpointClient(networkClient: network).fetchNonce(url: url)

    let sent = try #require(await network.lastRequest)
    #expect(nonce == "nonce-1")
    #expect(sent.url == url)
    #expect(sent.method == .post)
  }

  @Test func `a plain request posts the credential request as JSON with the authorization`()
    async throws
  {
    let network = FakeNetworkClient(body: credentialResponse(["issued-sd-jwt"]))

    let credential = try await fetchCredential(through: network)

    let sent = try #require(await network.lastRequest)
    let data = try #require(sent.body)
    let body = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    #expect(credential == "issued-sd-jwt")
    #expect(sent.url == credentialUrl)
    #expect(sent.method == .post)
    #expect(sent.contentType == "application/json")
    #expect(sent.accept == "application/json")
    #expect(body?["credential_configuration_id"] as? String == "pid")
    #expect((body?["proofs"] as? [String: [String]])?["jwt"] == ["proof-jwt"])
    #expect(body?["credential_response_encryption"] == nil)

    guard case .bearer("token")? = sent.authorization else {
      Issue.record("expected the bearer authorization to be passed through")
      return
    }
  }

  @Test func `only the first credential of the response is used`() async throws {
    let network = FakeNetworkClient(body: credentialResponse(["first", "second"]))

    let credential = try await fetchCredential(through: network)

    #expect(credential == "first")
  }

  @Test func `an empty credentials array is an invalid credential`() async throws {
    let network = FakeNetworkClient(body: credentialResponse([]))

    await #expect(throws: IssuanceError.invalidCredential) {
      try await fetchCredential(through: network)
    }
  }

  @Test func `a network failure propagates untouched`() async throws {
    let network = FakeNetworkClient(error: URLError(.timedOut))

    await #expect(throws: URLError.self) {
      try await fetchCredential(through: network)
    }
  }

  @Test func `an encrypted request round-trips through JWEs in both directions`() async throws {
    let issuer = EncryptingIssuer()
    let network = FakeNetworkClient { try await issuer.handle($0) }

    let credential = try await fetchCredential(through: network, requestEncryption: issuer.spec)

    let sent = try #require(await network.lastRequest)
    let received = try #require(await issuer.receivedRequests.first)
    let encryption = try #require(received.credentialResponseEncryption)
    #expect(credential == "issued-sd-jwt")
    #expect(sent.contentType == "application/jwt")
    #expect(sent.accept == "application/jwt")
    #expect(received.credentialConfigurationId == "pid")
    #expect(received.proofs.jwt == ["proof-jwt"])
    #expect(encryption.enc == "A128GCM")
    #expect(encryption.jwk.algorithm == "ECDH-ES")
    #expect(encryption.jwk.d == nil, "the ephemeral private key must stay in the wallet")
  }

  @Test func `each encrypted request uses a fresh ephemeral key`() async throws {
    let issuer = EncryptingIssuer()
    let network = FakeNetworkClient { try await issuer.handle($0) }

    for _ in 0 ..< 2 {
      _ = try await fetchCredential(through: network, requestEncryption: issuer.spec)
    }

    let advertisedKeys = await issuer.receivedRequests.map { received in
      received.credentialResponseEncryption?.jwk.x
    }
    #expect(advertisedKeys.count == 2)
    #expect(Set(advertisedKeys).count == 2)
  }
}
