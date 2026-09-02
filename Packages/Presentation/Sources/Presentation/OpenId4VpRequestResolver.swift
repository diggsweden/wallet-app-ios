// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CryptoKit
import Foundation
import Jose
import OpenID4VP
import OpenId4VCInterface
import eudi_lib_sdjwt_swift

struct OpenId4VpRequestResolver {
  func resolve(url: URL) async throws -> PresentationRequestData {
    // TODO: Replace with real x509 trust evaluation before production use.
    let certificateTrustMock: CertificateTrust = { _ in true }
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
      alg: "ECDH-ES",
    )

    let config = OpenId4VPConfiguration(
      privateKey: secKey,
      publicWebKeySet: WebKeySet(keys: [webKey]),
      supportedClientIdSchemes: [.x509SanDns(trust: certificateTrustMock)],
      responseEncryptionConfiguration:
        .supported(supportedAlgorithms: [.init(.ECDH_ES)], supportedMethods: [.init(.A128GCM)]),
    )

    let sdk = OpenID4VP(walletConfiguration: config)
    let result = await sdk.authorize(
      fetcher: Fetcher<String>(session: config.session),
      poster: Poster(session: config.session),
      url: url,
    )

    let resolvedRequest =
      switch result {
        case .notSecured(let request, _), .jwt(let request, _):
          request

        case .invalidResolution(let error, _):
          throw PresentationError.resolutionFailed("\(error)")
      }

    return try Self.requestData(from: resolvedRequest.request)
  }

  static func requestData(
    from data: ResolvedRequestData.VpTokenData
  ) throws
    -> PresentationRequestData
  {
    guard case let .byDigitalCredentialsQuery(dcql) = data.presentationQuery else {
      throw PresentationError.unsupportedQuery
    }

    guard case let .directPost(responseURI: responseUrl) = data.responseMode else {
      throw PresentationError.unsupportedResponseMode
    }

    return PresentationRequestData(
      credentialQueries: credentialQueries(from: dcql),
      responseUrl: responseUrl,
      clientId: data.client.id.clientId,
      nonce: data.nonce,
      state: data.state,
    )
  }

  static func credentialQueries(from dcql: DCQL) -> [CredentialQuery] {
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

      return CredentialQuery(
        id: credential.id.value,
        claimPaths: Set(claimPaths),
        required: isRequired(credential.id, in: dcql.credentialSets),
        vctValues: credential.meta["vct_values"].arrayValue.compactMap(\.string),
      )
    }
  }

  private static func isRequired(_ queryId: QueryId, in credentialSets: CredentialSets?) -> Bool {
    guard let credentialSets else {
      return true
    }

    let matchingSets = credentialSets.filter { set in
      set.options.contains { $0.contains(queryId) }
    }

    return matchingSets.contains { $0.required ?? true }
  }
}
