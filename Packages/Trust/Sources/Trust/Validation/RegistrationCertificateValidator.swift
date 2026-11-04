// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Jose
import X509

public enum RegistrationCertificateValidator {
  @discardableResult public static func validate(
    _ compactSerializedString: String,
    with trustAnchors: [SecCertificate],
    // TODO: Make check mandatory once pid-issuer reg. cert has been updated
    matchingAccessCertificate: Certificate?,
  ) throws -> RegistrationCertificate {
    let cert: RegistrationCertificate = try JwtUtil.parseJws(
      from: compactSerializedString,
      expectedType: .registrationCertificate,
    ) { certificateChain in
      try CertificateValidator.validate(base64CertChain: certificateChain, with: trustAnchors)
    }

    guard !cert.isExpired(at: .now) else {
      throw ValidationError.expiredCertificate
    }

    if let matchingAccessCertificate {
      guard
        let organizationIdentifier = matchingAccessCertificate.organizationIdentifier,
        cert.sub == organizationIdentifier
      else {
        throw ValidationError.accessCertificateMismatch
      }
    }

    return cert
  }
}
