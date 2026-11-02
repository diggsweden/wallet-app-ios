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
  var registrationCertificates: [String] {
    guard let issuerInfo else {
      return []
    }

    return issuerInfo.attestations
      .compactMap { issuerInfo in
        guard RegistrationCertificateFormat(rawValue: issuerInfo.format) != nil else {
          return nil
        }
        return issuerInfo.data
      }
  }

  func validateRegistrationCertificates(trustStore: any TrustStoreInterface) async throws {
    guard !registrationCertificates.isEmpty else {
      return
    }

    let trustAnchors = try await trustStore.getAllTrustAnchors()

    for certificate in registrationCertificates {
      let cert: RegistrationCertificate = try JwtUtil.parseJws(
        from: certificate,
        expectedType: .registrationCertificate,
      ) { certificateChain in
        try CertificateValidator.validate(certChain: certificateChain, with: trustAnchors)
      }

      guard !cert.isExpired(at: .now) else {
        throw ValidationError.expiredCertificate
      }
    }
  }
}
