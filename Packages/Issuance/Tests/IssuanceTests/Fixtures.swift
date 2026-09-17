// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfacesTestSupport
import CryptoKit
import Foundation
import Jose
import OpenID4VCI
import Testing

@testable import Issuance

/// Builds credential offers from issuer metadata JSON, the way the OpenID4VCI
/// library parses it in production.
enum Fixtures {
  static let issuerId = "https://issuer.example"
  static let credentialEndpoint = "https://issuer.example/credential"
  static let nonceEndpoint = "https://issuer.example/nonce"
  static let authorizationServer = "https://auth.example"
  static let sdJwtConfigurationId = "eu.europa.ec.eudi.pid_vc_sd_jwt"
  static let mdocConfigurationId = "eu.europa.ec.eudi.pid_mdoc"

  struct RequestEncryption {
    let key: P256.KeyAgreement.PublicKey
    var method = "A128GCM"
    var required = true
  }

  static func offer(
    configurationIds: [String] = [sdJwtConfigurationId],
    requestEncryption: RequestEncryption? = nil,
    keyAttestationsRequired: String? = nil,
  ) throws -> CredentialOffer {
    try CredentialOffer(
      credentialIssuerIdentifier: CredentialIssuerId(issuerId),
      credentialIssuerMetadata: issuerMetadata(
        requestEncryption: requestEncryption,
        keyAttestationsRequired: keyAttestationsRequired,
      ),
      credentialConfigurationIdentifiers: configurationIds.map { id in
        try CredentialConfigurationIdentifier(value: id)
      },
      authorizationServerMetadata: authorizationServerMetadata(),
    )
  }

  /// `keyAttestationsRequired` is the raw JSON of the SD-JWT configuration's
  /// `key_attestations_required` member; `nil` omits it.
  static func issuerMetadata(
    requestEncryption: RequestEncryption? = nil,
    keyAttestationsRequired: String? = nil,
  ) throws -> CredentialIssuerMetadata {
    let encryptionMember = try requestEncryption.map { try getEncryptionMember($0) } ?? ""

    let json = #"""
      {
        "credential_issuer": "\#(issuerId)",
        "authorization_servers": ["\#(authorizationServer)"],
        "credential_endpoint": "\#(credentialEndpoint)",
        "nonce_endpoint": "\#(nonceEndpoint)",
        \#(encryptionMember)
        "credential_configurations_supported": {
          "\#(sdJwtConfigurationId)": \#(sdJwtConfiguration(keyAttestationsRequired)),
          "\#(mdocConfigurationId)": \#(mdocConfiguration)
        }
      }
      """#

    return try JSONDecoder().decode(CredentialIssuerMetadata.self, from: Data(json.utf8))
  }

  static func authorizationServerMetadata(
    dpop: Bool = true
  ) throws -> IdentityAndAccessManagementMetadata {
    let dpopMember = dpop ? #""dpop_signing_alg_values_supported": ["ES256"],"# : ""
    let json = #"""
      {
        "issuer": "\#(authorizationServer)",
        \#(dpopMember)
        "authorization_endpoint": "\#(authorizationServer)/authorize",
        "token_endpoint": "\#(authorizationServer)/token"
      }
      """#

    return .oauth(
      try JSONDecoder().decode(AuthorizationServerMetadata.self, from: Data(json.utf8))
    )
  }

  private static func getEncryptionMember(_ encryption: RequestEncryption) throws -> String {
    let jwk = try #require(
      String(bytes: JSONEncoder().encode(WalletJoseJWK(encryption.key)), encoding: .utf8)
    )

    return #"""
      "credential_request_encryption": {
        "jwks": {"keys": [\#(jwk)]},
        "enc_values_supported": ["\#(encryption.method)"],
        "encryption_required": \#(encryption.required)
      },
      """#
  }

  private static func sdJwtConfiguration(_ keyAttestationsRequired: String?) -> String {
    let keyAttestationsMember = keyAttestationsRequired.map { member in
      #", "key_attestations_required": \#(member)"#
    } ?? ""

    return #"""
      {
        "format": "dc+sd-jwt",
        "vct": "\#(SampleCredential.pidType)",
        "cryptographic_binding_methods_supported": ["jwk"],
        "credential_signing_alg_values_supported": ["ES256"],
        "proof_types_supported": {
          "jwt": {
            "proof_signing_alg_values_supported": ["ES256"]\#(keyAttestationsMember)
          }
        }
      }
      """#
  }

  private static let mdocConfiguration = #"""
    {
      "format": "mso_mdoc",
      "doctype": "eu.europa.ec.eudi.pid.1",
      "cryptographic_binding_methods_supported": ["cose_key"]
    }
    """#
}
