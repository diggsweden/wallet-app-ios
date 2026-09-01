// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import JSONWebSignature

extension WalletJWSHeader {
  init(_ header: DefaultJWSHeaderImpl) {
    self.init(
      algorithm: header.algorithm.map { WalletJoseSigningAlgorithm($0) },
      keyID: header.keyID,
      jwkSetURL: header.jwkSetURL,
      x509URL: header.x509URL,
      x509CertificateChain: header.x509CertificateChain,
      x509CertificateSHA1Thumbprint: header.x509CertificateSHA1Thumbprint,
      x509CertificateSHA256Thumbprint: header.x509CertificateSHA256Thumbprint,
      type: header.type,
      contentType: header.contentType,
      critical: header.critical,
      base64EncodedUrlPayload: header.base64EncodedUrlPayload,
    )
  }

  var joseHeader: DefaultJWSHeaderImpl {
    DefaultJWSHeaderImpl(
      algorithm: algorithm?.joseSigningAlgorithm,
      keyID: keyID,
      jwkSetURL: jwkSetURL,
      x509URL: x509URL,
      x509CertificateChain: x509CertificateChain,
      x509CertificateSHA1Thumbprint: x509CertificateSHA1Thumbprint,
      x509CertificateSHA256Thumbprint: x509CertificateSHA256Thumbprint,
      type: type,
      contentType: contentType,
      critical: critical,
      base64EncodedUrlPayload: base64EncodedUrlPayload,
    )
  }
}
