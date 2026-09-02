// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

public struct WalletKeyAttestationHeader: WalletJWSHeader {
  public var algorithm: WalletJoseSigningAlgorithm? = .ES256
  public var keyID: String?
  public var jwkSetURL: String?
  public var jwk: WalletJoseJWK?
  public var x509URL: String?
  public var x509CertificateChain: [String]?
  public var x509CertificateSHA1Thumbprint: String?
  public var x509CertificateSHA256Thumbprint: String?
  public var type: String? = "openid4vci-proof+jwt"
  public var contentType: String?
  public var critical: [String]?
  // swiftlint:disable:next discouraged_optional_boolean
  public var base64EncodedUrlPayload: Bool?
  public let keyAttestation: String?

  public init(
    jwk: WalletJoseJWK? = nil,
    keyID: String? = nil,
    keyAttestation: String?,
  ) {
    self.jwk = jwk
    self.keyID = keyID
    self.keyAttestation = keyAttestation
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
    case keyAttestation = "key_attestation"
  }
}
