// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Jose
import OpenID4VCI
import Trust

struct TrustStoreCertificateChainTrust: CertificateChainTrust {
  let trustStore: any TrustStoreInterface

  func isValid(chain: [String]) async -> Bool {
    do {
      let trustAnchors = try await trustStore.getAllTrustAnchors()
      _ = try CertificateValidator.validate(base64CertChain: chain, with: trustAnchors)
      return true
    } catch {
      return false
    }
  }
}

extension IssuerMetadataPolicy {
  static func preferSigned(trustStore: any TrustStoreInterface) -> IssuerMetadataPolicy {
    .preferSigned(
      issuerTrust: .byCertificateChain(
        certificateChainTrust: TrustStoreCertificateChainTrust(trustStore: trustStore)
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

  func validateRegistrationCertificates(trustStore: any TrustStoreInterface) async throws {
    guard !registrationCertificates.isEmpty else {
      return
    }

    let trustAnchors = try await trustStore.getAllTrustAnchors()

    for certificate in registrationCertificates {
      let _: VerifiedClaims = try JwtUtil.parseJws(from: certificate) { certificateChain in
        try CertificateValidator.validate(certChain: certificateChain, with: trustAnchors)
      }
    }
  }
}

private struct VerifiedClaims: Decodable {}
