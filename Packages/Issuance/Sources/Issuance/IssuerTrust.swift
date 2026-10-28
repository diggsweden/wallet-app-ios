// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Jose
import OpenID4VCI
import Trust

/// Trusts a certificate chain that validates against the trust anchors of a service type.
/// The anchors are only fetched once a chain needs checking.
struct TrustStoreCertificateChainTrust: CertificateChainTrust {
  let trustStore: any TrustStoreInterface
  let serviceType: ServiceType

  func isValid(chain: [String]) async -> Bool {
    do {
      let trustAnchors = try await trustStore.getTrustAnchors(for: serviceType.rawValue)
      _ = try CertificateValidator.validate(base64CertChain: chain, with: trustAnchors)
      return true
    } catch {
      return false
    }
  }
}

extension IssuerMetadataPolicy {
  /// Signed metadata is verified against the access certificate anchors; unsigned metadata is
  /// still accepted.
  static func preferSigned(trustStore: any TrustStoreInterface) -> IssuerMetadataPolicy {
    .preferSigned(
      issuerTrust: .byCertificateChain(
        certificateChainTrust: TrustStoreCertificateChainTrust(
          trustStore: trustStore,
          serviceType: .access,
        )
      )
    )
  }
}

extension CredentialIssuerMetadata {
  /// The registration certificates the issuer publishes in `issuer_info`.
  var registrationCertificates: [String] {
    issuerInfo?.attestations
      .filter { $0.format == ETSI119472Part3.REGISTRATION_CERT }
      .map(\.data) ?? []
  }

  /// Verifies every registration certificate against the registration anchors.
  /// An issuer without registration certificates passes without a trust store lookup.
  func validateRegistrationCertificates(trustStore: any TrustStoreInterface) async throws {
    guard !registrationCertificates.isEmpty else {
      return
    }

    let trustAnchors = try await trustStore.getTrustAnchors(
      for: ServiceType.registration.rawValue
    )

    for certificate in registrationCertificates {
      let _: VerifiedClaims = try JwtUtil.parseJws(from: certificate) { certificateChain in
        try CertificateValidator.validate(certChain: certificateChain, with: trustAnchors)
      }
    }
  }
}

// Only the signature and chain are checked for now; the issuer's registration claims are not read.
private struct VerifiedClaims: Decodable {}
