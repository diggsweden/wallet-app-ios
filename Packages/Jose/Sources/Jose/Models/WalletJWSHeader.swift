// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

public struct WalletJWSHeader: Codable, Sendable {
  public var algorithm: WalletJoseSigningAlgorithm?
  public var keyID: String?
  public var jwkSetURL: String?
  public var x509URL: String?
  public var x509CertificateChain: [String]?
  public var x509CertificateSHA1Thumbprint: String?
  public var x509CertificateSHA256Thumbprint: String?
  public var type: String?
  public var contentType: String?
  public var critical: [String]?
  // swiftlint:disable:next discouraged_optional_boolean
  public var base64EncodedUrlPayload: Bool?

  public init(
    algorithm: WalletJoseSigningAlgorithm? = nil,
    keyID: String? = nil,
    jwkSetURL: String? = nil,
    x509URL: String? = nil,
    x509CertificateChain: [String]? = nil,
    x509CertificateSHA1Thumbprint: String? = nil,
    x509CertificateSHA256Thumbprint: String? = nil,
    type: String? = nil,
    contentType: String? = nil,
    critical: [String]? = nil,
    // swiftlint:disable:next discouraged_optional_boolean
    base64EncodedUrlPayload: Bool? = nil,
  ) {
    self.algorithm = algorithm
    self.keyID = keyID
    self.jwkSetURL = jwkSetURL
    self.x509URL = x509URL
    self.x509CertificateChain = x509CertificateChain
    self.x509CertificateSHA1Thumbprint = x509CertificateSHA1Thumbprint
    self.x509CertificateSHA256Thumbprint = x509CertificateSHA256Thumbprint
    self.type = type
    self.contentType = contentType
    self.critical = critical
    self.base64EncodedUrlPayload = base64EncodedUrlPayload
  }
}
