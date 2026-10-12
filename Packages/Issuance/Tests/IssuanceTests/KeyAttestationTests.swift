// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import OpenID4VCI
import OpenId4VCInterface
import OpenId4VCInterfaceTestSupport
import Testing

@testable import Issuance

struct KeyAttestationTests {
  private let proofKey = FakeProofSigner().proofKey

  @Test(arguments: [
    KeyAttestationRequirement.requiredNoConstraints,
    .required(
      keyStorageConstraints: [.iso18045High],
      userAuthenticationConstraints: [.iso18045High],
      preferredKeyStorageStatusPeriod: nil,
    ),
  ])
  func `a required attestation covers exactly the new proof key and carries the nonce`(
    requirement: KeyAttestationRequirement
  ) async throws {
    let attestations = FakeKeyAttestationProvider(attestation: "attestation-jwt")

    let attestation = try await IssuanceSession.keyAttestation(
      requirement: requirement,
      proofKey: proofKey,
      nonce: "nonce-1",
      attestations: attestations,
    )

    let requests = await attestations.requests
    #expect(attestation == "attestation-jwt")
    #expect(requests.count == 1)
    #expect(requests.first?.publicKeys == [proofKey.publicKey])
    #expect(requests.first?.nonce == "nonce-1")
  }

  @Test(arguments: [KeyAttestationRequirement.notRequired, nil])
  func `no attestation is requested when the issuer does not require one`(
    requirement: KeyAttestationRequirement?
  ) async throws {
    let attestations = FakeKeyAttestationProvider()

    let attestation = try await IssuanceSession.keyAttestation(
      requirement: requirement,
      proofKey: proofKey,
      nonce: "nonce-1",
      attestations: attestations,
    )

    #expect(attestation == nil)
    #expect(await attestations.requests.isEmpty)
  }

  @Test func `issuer metadata with key storage constraints asks for an attestation`() throws {
    let configuration =
      try Fixtures.offer(
        keyAttestationsRequired: #"""
          {"key_storage": ["iso_18045_high"], "user_authentication": ["iso_18045_moderate"]}
          """#
      )
      .sdJwtVcConfiguration().configuration

    let requirement = configuration.proofTypesSupported?["jwt"]?.keyAttestationRequirement
    #expect(
      requirement
        == .required(
          keyStorageConstraints: [.iso18045High],
          userAuthenticationConstraints: [.iso18045Moderate],
          preferredKeyStorageStatusPeriod: nil,
        )
    )
  }

  // OpenID4VCI 1.0 §12.2.4: an empty `key_attestations_required` object means an
  // attestation is required without constraints.
  @Test func `an empty key_attestations_required object asks for an attestation`() throws {
    let configuration = try Fixtures.offer(keyAttestationsRequired: "{}")
      .sdJwtVcConfiguration().configuration

    let requirement = configuration.proofTypesSupported?["jwt"]?.keyAttestationRequirement
    #expect(requirement == .requiredNoConstraints)
  }

  @Test func `issuer metadata without key_attestations_required asks for none`() throws {
    let configuration = try Fixtures.offer().sdJwtVcConfiguration().configuration

    #expect(configuration.proofTypesSupported?["jwt"]?.keyAttestationRequirement == .notRequired)
  }
}
