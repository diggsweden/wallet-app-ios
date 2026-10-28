// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import OpenID4VCI
import Testing
import Trust

@testable import Issuance

/// Hands out no anchors and records which service types were asked for.
private actor RecordingTrustStore: TrustStoreInterface {
  private(set) var requestedServiceTypes: [String] = []

  func getTrustAnchors(for serviceType: String) -> [SecCertificate] {
    requestedServiceTypes.append(serviceType)
    return []
  }
}

struct IssuerTrustTests {
  @Test func `signed metadata is preferred and checked against the access anchors`() throws {
    let policy = IssuerMetadataPolicy.preferSigned(trustStore: RecordingTrustStore())

    guard case .preferSigned(.byCertificateChain(let chainTrust)) = policy else {
      Issue.record("Expected a preferSigned policy trusting by certificate chain")
      return
    }

    let trust = try #require(chainTrust as? TrustStoreCertificateChainTrust)
    #expect(trust.serviceType == .access)
  }

  @Test func `a chain is not trusted without anchors for its service type`() async {
    let trustStore = RecordingTrustStore()
    let trust = TrustStoreCertificateChainTrust(trustStore: trustStore, serviceType: .access)

    #expect(await trust.isValid(chain: ["MIIB"]) == false)
    #expect(await trustStore.requestedServiceTypes == [ServiceType.access.rawValue])
  }

  @Test func `only registration certificate attestations are read from issuer_info`() throws {
    let metadata = try Fixtures.issuerMetadata(
      issuerInfo: #"""
        [
          {"format": "registration_cert", "data": "registration-jwt"},
          {"format": "other", "data": "other-data"}
        ]
        """#
    )

    #expect(metadata.registrationCertificates == ["registration-jwt"])
  }

  @Test func `a bare issuer_info string is a registration certificate`() throws {
    let metadata = try Fixtures.issuerMetadata(issuerInfo: #""registration-jwt""#)

    #expect(metadata.registrationCertificates == ["registration-jwt"])
  }

  @Test func `an issuer without registration certificates needs no trust anchors`() async throws {
    let trustStore = RecordingTrustStore()

    try await Fixtures.issuerMetadata().validateRegistrationCertificates(trustStore: trustStore)

    #expect(await trustStore.requestedServiceTypes.isEmpty)
  }

  @Test func `an unverifiable registration certificate is rejected`() async throws {
    let trustStore = RecordingTrustStore()
    let metadata = try Fixtures.issuerMetadata(
      issuerInfo: #"[{"format": "registration_cert", "data": "not-a-jwt"}]"#
    )

    await #expect(throws: (any Error).self) {
      try await metadata.validateRegistrationCertificates(trustStore: trustStore)
    }
    #expect(await trustStore.requestedServiceTypes == [ServiceType.registration.rawValue])
  }
}
