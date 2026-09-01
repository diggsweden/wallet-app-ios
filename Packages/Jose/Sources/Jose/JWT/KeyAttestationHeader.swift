// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import JSONWebAlgorithms
import JSONWebKey
import JSONWebSignature

struct KeyAttestationHeader: JWSRegisteredFieldsHeader {
  var algorithm: JSONWebAlgorithms.SigningAlgorithm? = .ES256
  var jwkSetURL: String?
  var jwk: JSONWebKey.JWK?
  var keyID: String?
  var x509URL: String?
  var x509CertificateChain: [String]?
  var x509CertificateSHA1Thumbprint: String?
  var x509CertificateSHA256Thumbprint: String?
  var type: String? = "openid4vci-proof+jwt"
  var contentType: String?
  var critical: [String]?
  var base64EncodedUrlPayload: Bool?  // swiftlint:disable:this discouraged_optional_boolean
  let keyAttestation: String?

  enum CodingKeys: String, CodingKey {
    case algorithm = "alg"
    case jwkSetURL = "jku"
    case jwk
    case keyID = "kid"
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
