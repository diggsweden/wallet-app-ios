// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CryptoKit
import Foundation
import JSONWebKey
import OpenID4VP
import eudi_lib_sdjwt_swift

struct OpenId4VpUtil {
  private let certificateTrustMock: CertificateTrust = { _ in true }

  private func isCredentialRequired(
    _ queryId: QueryId,
    in credentialSets: CredentialSets?
  ) -> Bool {
    guard let credentialSets else {
      return true
    }

    let matchingSets = credentialSets.filter { set in
      set.options.contains { $0.contains(queryId) }
    }

    return matchingSets.contains { $0.required ?? true }
  }

  private func mapCredentialQueries(_ dcql: DCQL) -> [CredentialQuery] {
    dcql.credentials.map { credential in
      let claimPaths =
        credential.claims?
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
        } ?? []

      let required = isCredentialRequired(credential.id, in: dcql.credentialSets)

      return CredentialQuery(
        id: credential.id.value,
        claimPaths: Set(claimPaths),
        required: required
      )
    }
  }

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
          throw PresentationError.resolutionFailed("\(error)")
      }

    let data = resolvedRequest.request

    guard case let .byDigitalCredentialsQuery(dcql) = data.presentationQuery else {
      throw PresentationError.unsupportedQuery
    }

    guard case let .directPost(responseURI: responseUrl) = data.responseMode else {
      // DirectPostJwt is not yet supported
      throw PresentationError.unsupportedResponseMode
    }

    let credentialQueries = mapCredentialQueries(dcql)

    let recipientJWK = try? data.clientMetaData?.jwkSet?.keys.first?.toJWK()

    return PresentationRequestData(
      credentialQueries: credentialQueries,
      responseUrl: responseUrl,
      clientId: data.client.id.originalClientId,
      nonce: data.nonce,
      state: data.state,
      recipientJWK: recipientJWK
    )
  }
}
