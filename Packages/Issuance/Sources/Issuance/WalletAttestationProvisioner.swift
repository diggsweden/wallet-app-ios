// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CryptoKit
import Foundation
import JOSESwift
import Jose
import OpenID4VCI
import OpenId4VCInterface

/// Provisions the Wallet Instance Attestation used for attestation-based client authentication,
/// bound to an ephemeral key that also signs the attestation PoP.
actor WalletAttestationProvisioner {
  private struct Expiry: Decodable {
    let exp: TimeInterval
  }

  private let attestations: any WalletInstanceAttestationProviding
  private let privateKey: P256.Signing.PrivateKey
  private var cached: (attestation: ClientAttestationJWT, expiresAt: Date)?

  init(
    attestations: any WalletInstanceAttestationProviding,
    privateKey: P256.Signing.PrivateKey = P256.Signing.PrivateKey(),
  ) {
    self.attestations = attestations
    self.privateKey = privateKey
  }

  nonisolated func client(id: ClientId) throws -> Client {
    let publicKey = WalletJoseJWK(privateKey.publicKey)
    guard let x = publicKey.x, let y = publicKey.y else {
      throw KeyConversionError.conversionFailed
    }

    return try Client(
      id: id,
      alg: JWSAlgorithm(.ES256),
      jwk: ECPublicKey(
        crv: .P256,
        x: x.base64UrlEncodedString(),
        y: y.base64UrlEncodedString(),
      ),
      popJwtSpec: ClientAttestationPoPJWTSpec(
        signingAlgorithm: .ES256,
        typ: AttestationBasedClientAuthenticationSpec.attestationPopJwtType,
      ),
      clientAttestationProvider: { _ in
        (try await self.clientAttestation(), .secKey(try self.privateKey.toSecKey()))
      },
    )
  }

  // The library asks for the attestation more than once per request,
  // so it is reused until it expires.
  func clientAttestation() async throws -> ClientAttestationJWT {
    if let cached, cached.expiresAt > .now {
      return cached.attestation
    }

    // The gateway requires a key ID on the attested key.
    var publicKey = WalletJoseJWK(privateKey.publicKey)
    publicKey.keyID = try publicKey.thumbprint()

    let attestation = ClientAttestationJWT(
      try await attestations.walletInstanceAttestation(for: publicKey)
    )
    let expiry = try attestation.decodeClaimsSet(Expiry.self)
    cached = (attestation, Date(timeIntervalSince1970: expiry.exp))
    return attestation
  }
}

extension IdentityAndAccessManagementMetadata {
  /// Whether the authorization server accepts a Wallet Instance Attestation signed with ES256.
  var supportsWalletAttestation: Bool {
    tokenEndpointAuthMethodsSupported.contains("attest_jwt_client_auth")
      && clientAttestationSigningAlgValuesSupported.contains { algorithm in
        algorithm.name == JWSAlgorithm.AlgorithmType.ES256.rawValue
      }
  }

  private var tokenEndpointAuthMethodsSupported: [String] {
    switch self {
      case .oidc(let metadata):
        metadata.tokenEndpointAuthMethodsSupported ?? []

      case .oauth(let metadata):
        metadata.tokenEndpointAuthMethodsSupported ?? []
    }
  }
}
