// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Jose

public enum CertificateValidator {
  public static func validate(
    base64CertChain: [String],
    with trustAnchors: [SecCertificate],
  ) throws -> SecKey {
    let certificates = try base64CertChain.map { encoded in
      guard
        let data = Data(base64UrlEncoded: encoded),
        let certificate = SecCertificateCreateWithData(nil, data as CFData)
      else {
        throw ValidationError.invalidCertificate
      }

      return certificate
    }

    return try validate(certChain: certificates, with: trustAnchors)
  }

  public static func validate(
    certChain: [SecCertificate],
    with trustAnchors: [SecCertificate],
  ) throws -> SecKey {
    if certChain.isEmpty {
      throw ValidationError.emptyCertificateChain
    }

    if trustAnchors.isEmpty {
      throw ValidationError.emptyTrustAnchors
    }

    var trust: SecTrust?
    let policy = SecPolicyCreateBasicX509()
    let status = SecTrustCreateWithCertificates(certChain as CFArray, policy, &trust)

    guard status == errSecSuccess, let trust else {
      throw ValidationError.trustCreationFailed(status)
    }

    SecTrustSetAnchorCertificates(trust, trustAnchors as CFArray)
    SecTrustSetAnchorCertificatesOnly(trust, true)
    SecTrustSetNetworkFetchAllowed(trust, false)

    var error: CFError?
    guard SecTrustEvaluateWithError(trust, &error) else {
      throw (error as Error?) ?? ValidationError.evaluationFailed
    }

    guard let key = SecTrustCopyKey(trust) else {
      throw ValidationError.noPublicKey
    }
    return key
  }
}
