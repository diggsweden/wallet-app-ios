// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

public struct WalletJWSDefaultHeader: WalletJWSHeader {
  public var algorithm: WalletJoseSigningAlgorithm?
  public var keyID: String?
  public var jwkSetURL: String?
  public var jwk: WalletJoseJWK?
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
    jwk: WalletJoseJWK? = nil,
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
    self.jwk = jwk
    self.x509URL = x509URL
    self.x509CertificateChain = x509CertificateChain
    self.x509CertificateSHA1Thumbprint = x509CertificateSHA1Thumbprint
    self.x509CertificateSHA256Thumbprint = x509CertificateSHA256Thumbprint
    self.type = type
    self.contentType = contentType
    self.critical = critical
    self.base64EncodedUrlPayload = base64EncodedUrlPayload
  }

  enum CodingKeys: String, CodingKey {
    case algorithm = "alg"
    case keyID = "kid"
    case jwkSetURL = "jku"
    case jwk
    case x509URL = "x5u"
    case x509CertificateChain = "x5c"
    case x509CertificateSHA1Thumbprint = "x5t"
    case x509CertificateSHA256Thumbprint = "x5t#S256"
    case type = "typ"
    case contentType = "cty"
    case critical = "crit"
    case base64EncodedUrlPayload = "b64"
  }
}
