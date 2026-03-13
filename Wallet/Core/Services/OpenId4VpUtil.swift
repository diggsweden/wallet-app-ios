// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CryptoKit
import Foundation
import JSONWebKey
import OpenID4VP
import eudi_lib_sdjwt_swift

struct PresentationRequestData {
  let claimPaths: Set<eudi_lib_sdjwt_swift.ClaimPath>
  let credentialQueryId: String
  let responseUrl: URL
  let clientId: String
  let nonce: String
  let state: String?
  let recipientJWK: JWK?
}

struct OpenId4VpUtil {
  private let certificateTrustMock: CertificateTrust = { _ in true }

  func resolve(url: URL) async throws -> PresentationRequestData {
    let ephemeralKey = P256.Signing.PrivateKey()
    let secKey = try ephemeralKey.toSecKey()
    let rawRep = ephemeralKey.publicKey.rawRepresentation
    let x = rawRep.prefix(32)
    let y = rawRep.suffix(32)

    let webKey = WebKeySet.Key(
      kty: "EC",
      use: nil,
      kid: nil,
      iat: nil,
      crv: "P-256",
      x: x.base64UrlEncodedString(),
      y: y.base64UrlEncodedString(),
      exponent: nil,
      modulus: nil,
      alg: "ECDH-ES"
    )

    let config = OpenId4VPConfiguration(
      privateKey: secKey,
      publicWebKeySet: WebKeySet(keys: [webKey]),
      supportedClientIdSchemes: [.x509SanDns(trust: certificateTrustMock)],
      responseEncryptionConfiguration:
        .supported(supportedAlgorithms: [.init(.ECDH_ES)], supportedMethods: [.init(.A128GCM)])
    )

    let sdk = OpenID4VP(walletConfiguration: config)
    let result = await sdk.authorize(url: url)

    let resolvedRequest =
      switch result {
        case .notSecured(let request), .jwt(let request):
          request
        case .invalidResolution(let error, _):
          throw AppError(reason: "Failed to resolve presentation request: \(error)")
      }

    let data = resolvedRequest.request

    guard case let .byDigitalCredentialsQuery(dcql) = data.presentationQuery else {
      throw AppError(reason: "Only DCQL queries are supported")
    }

    guard case let .directPost(responseURI: responseUrl) = data.responseMode else {
      // TODO: Support DirectPostJwt
      throw AppError(reason: "Only direct_post response mode is supported")
    }

    let claimPaths = dcql.credentials
      .flatMap { $0.claims ?? [] }
      .map { claim in
        eudi_lib_sdjwt_swift.ClaimPath(
          claim.path.value.map { element in
            switch element {
              case .claim(let name): .claim(name: name)
              case .arrayElement(let index): .arrayElement(index: index)
              case .allArrayElements: .allArrayElements
            }
          }
        )
      }

    let credentialQueryId = dcql.credentials.first?.id.value ?? ""

    let recipientJWK = try? data.clientMetaData?.jwkSet?.keys.first?.toJWK()

    return PresentationRequestData(
      claimPaths: Set(claimPaths),
      credentialQueryId: credentialQueryId,
      responseUrl: responseUrl,
      clientId: data.client.id.originalClientId,
      nonce: data.nonce,
      state: data.state,
      recipientJWK: recipientJWK
    )
  }
}
