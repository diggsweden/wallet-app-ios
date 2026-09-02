// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

public protocol WalletJWSHeader: Encodable, Sendable {
  var algorithm: WalletJoseSigningAlgorithm? { get set }
  var keyID: String? { get set }
  var jwkSetURL: String? { get set }
  var jwk: WalletJoseJWK? { get set }
  var x509URL: String? { get set }
  var x509CertificateChain: [String]? { get set }
  var x509CertificateSHA1Thumbprint: String? { get set }
  var x509CertificateSHA256Thumbprint: String? { get set }
  var type: String? { get set }
  var contentType: String? { get set }
  var critical: [String]? { get set }
  // swiftlint:disable:next discouraged_optional_boolean
  var base64EncodedUrlPayload: Bool? { get set }
}
