// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import OpenID4VCI
import Testing
import Trust

@testable import Issuance

/// Hands out no anchors and counts how often all anchors were asked for.
private actor RecordingTrustStore: TrustStoreInterface {
  private(set) var allTrustAnchorsLookups = 0

  func getTrustAnchors(for serviceType: String) -> [SecCertificate] { [] }

  func getAllTrustAnchors() -> [SecCertificate] {
    allTrustAnchorsLookups += 1
    return []
  }
}

struct IssuerTrustTests {
  @Test func `signed metadata is preferred and checked against the trust store`() {
    let policy = IssuerMetadataPolicy.preferSigned(trustStore: RecordingTrustStore())

    guard case .preferSigned(.byCertificateChain(let chainTrust)) = policy else {
      Issue.record("Expected a preferSigned policy trusting by certificate chain")
      return
    }

    #expect(chainTrust is TrustStoreCertificateChainTrust)
  }

  @Test func `a chain is not trusted without anchors`() async {
    let trustStore = RecordingTrustStore()
    let trust = TrustStoreCertificateChainTrust(trustStore: trustStore)

    #expect(await trust.isValid(chain: ["MIIB"]) == false)
    #expect(await trustStore.allTrustAnchorsLookups == 1)
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

    #expect(await trustStore.allTrustAnchorsLookups == 0)
  }

  @Test func `an unverifiable registration certificate is rejected`() async throws {
    let trustStore = RecordingTrustStore()
    let metadata = try Fixtures.issuerMetadata(
      issuerInfo: #"[{"format": "registration_cert", "data": "not-a-jwt"}]"#
    )

    await #expect(throws: (any Error).self) {
      try await metadata.validateRegistrationCertificates(trustStore: trustStore)
    }
    #expect(await trustStore.allTrustAnchorsLookups == 1)
  }
  // TODO: Re-enable once pid-issuer fixes their reg. certificate
  //  @Test(arguments: [nil, "not base64", Data("not DER".utf8).base64EncodedString()])
  //  func `missing or malformed access certificates are rejected`(wrpac: String?) async throws {
  //    let trustStore = RecordingTrustStore()
  //    let metadata = try Fixtures.issuerMetadata(
  //      issuerInfo: #""registration-jwt""#,
  //      wrpac: wrpac,
  //    )
  //
  //    await #expect(throws: (any Error).self) {
  //      try await metadata.validateRegistrationCertificates(trustStore: trustStore)
  //    }
  //    #expect(await trustStore.allTrustAnchorsLookups == 0)
  //  }
  //
  //  private static let accessCertificate = """
  //    MIIBmjCCAUGgAwIBAgIUQ4lx3yVbRV9+AluDYDFKEpHVx6swCgYIKoZIzj0EAwIwGjEYMBYGA1UE
  //    AwwPVHJ1c3QgVGVzdCBSb290MCAXDTI2MTAyMDEyNTYwMloYDzIxMjYwOTI2MTI1NjAyWjAaMRgw
  //    FgYDVQQDDA9UcnVzdCBUZXN0IFJvb3QwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAARKLIInVXPH
  //    AhAs33KpE4a6TEbQlfulvBrMyuvb2p85yU6rJIm0xJXoK743L+P9vvZwh/CwO76AfngfPtiJBbXh
  //    o2MwYTAdBgNVHQ4EFgQUxKk8CzTUYuWq6By9UjZJj0tMZ7QwHwYDVR0jBBgwFoAUxKk8CzTUYuWq
  //    6By9UjZJj0tMZ7QwDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8EBAMCAQYwCgYIKoZIzj0EAwID
  //    RwAwRAIgemOADQG+2NcHITXwy0XlqHwO4Izhrr78kTUyWhIrAoMCIBohYzoy3BIjfA5nRPc/Ftvm
  //    7OLaFYBDPhj75rr3GKS6
  //    """
  //    .replacingOccurrences(of: "\n", with: "")
}
