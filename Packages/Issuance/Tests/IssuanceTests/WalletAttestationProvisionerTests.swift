// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CryptoKit
import Foundation
import Jose
import JoseTestSupport
import OpenID4VCI
import OpenId4VCInterfaceTestSupport
import Testing
import WalletMacros

@testable import Issuance

private struct FixedClock: ClockType {
  func now() -> Date { Date(timeIntervalSince1970: 1_700_000_000) }
}

struct WalletAttestationProvisionerTests {
  private let privateKey = P256.Signing.PrivateKey()

  @Test func `the attestation is requested for the key that signs the pop`() async throws {
    let attestations = FakeWalletInstanceAttestationProvider(
      attestation: Self.attestation(expiringIn: 300)
    )
    let provisioner = WalletAttestationProvisioner(
      attestations: attestations,
      privateKey: privateKey,
    )
    let client = try provisioner.client(id: "wallet-dev")
    let provider = try #require(client.provider())

    let (attestation, _) = try await provider(#URL("https://auth.example"))
    let pop = try await DefaultClientAttestationPoPBuilder()
      .buildAttestationPoPJWT(
        for: client,
        algorithm: .ES256,
        clock: FixedClock(),
        authServerId: #URL("https://auth.example"),
        challenge: nil,
      )
    let decodedPop = try DecodedJwt(compact: pop.jws.compactSerializedString)

    var expectedKey = WalletJoseJWK(privateKey.publicKey)
    expectedKey.keyID = try expectedKey.thumbprint()
    #expect(attestation.value == attestations.attestation)
    #expect(await attestations.requestedKeys == [expectedKey])
    #expect(decodedPop.headerString("typ") == "oauth-client-attestation-pop+jwt")
    #expect(decodedPop.claim("iss") == "wallet-dev")
    #expect(try decodedPop.verifies(with: privateKey.publicKey))
  }

  @Test func `an unexpired attestation is reused`() async throws {
    let attestations = FakeWalletInstanceAttestationProvider(
      attestation: Self.attestation(expiringIn: 300)
    )
    let provisioner = WalletAttestationProvisioner(attestations: attestations)

    _ = try await provisioner.clientAttestation()
    _ = try await provisioner.clientAttestation()

    #expect(await attestations.requestedKeys.count == 1)
  }

  @Test func `an expired attestation is fetched again`() async throws {
    let attestations = FakeWalletInstanceAttestationProvider(
      attestation: Self.attestation(expiringIn: -1)
    )
    let provisioner = WalletAttestationProvisioner(attestations: attestations)

    _ = try await provisioner.clientAttestation()
    _ = try await provisioner.clientAttestation()

    #expect(await attestations.requestedKeys.count == 2)
  }

  @Test func `wallet attestation is used when the authorization server accepts it`() throws {
    let metadata = try Fixtures.authorizationServerMetadata(
      tokenEndpointAuthMethods: ["attest_jwt_client_auth"],
      clientAttestationAlgs: ["ES256"],
    )

    #expect(metadata.supportsWalletAttestation)
  }

  @Test func `wallet attestation is not used for public clients only`() throws {
    let metadata = try Fixtures.authorizationServerMetadata(
      tokenEndpointAuthMethods: ["none"],
      clientAttestationAlgs: ["ES256"],
    )

    #expect(metadata.supportsWalletAttestation == false)
  }

  @Test func `wallet attestation is not used when ES256 attestations are not accepted`() throws {
    let metadata = try Fixtures.authorizationServerMetadata(
      tokenEndpointAuthMethods: ["attest_jwt_client_auth"],
      clientAttestationAlgs: ["ES384"],
    )

    #expect(metadata.supportsWalletAttestation == false)
  }

  @Test func `wallet attestation is not used without client auth metadata`() throws {
    #expect(try Fixtures.authorizationServerMetadata().supportsWalletAttestation == false)
  }

  private static func attestation(expiringIn interval: TimeInterval) -> String {
    let exp = Int(Date.now.addingTimeInterval(interval).timeIntervalSince1970)
    let header = Data(#"{"alg":"ES256","typ":"oauth-client-attestation+jwt"}"#.utf8)
    let claims = Data(#"{"exp":\#(exp)}"#.utf8)
    return [header, claims, Data("signature".utf8)]
      .map { $0.base64UrlEncodedString() }
      .joined(separator: ".")
  }
}
