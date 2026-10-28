// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import CryptoKit
import Foundation
import Jose
import OpenID4VP
import OpenId4VCInterface
import Trust

struct OpenId4VpRequestResolver {
  func resolve(
    url: URL,
    accessTrustAnchors: [SecCertificate],
    registrationTrustAnchors: [SecCertificate],
  ) async throws -> PresentationRequestData {
    let certificateTrust: CertificateTrust = { certificateChain in
      validateAccessCertificates(
        certificateChain: certificateChain,
        trustAnchors: accessTrustAnchors,
      )
    }
    let (secKey, webKey) = try generateKey()
    let config = OpenId4VPConfiguration(
      privateKey: secKey,
      publicWebKeySet: WebKeySet(keys: [webKey]),
      supportedClientIdSchemes: [.x509SanDns(trust: certificateTrust)],
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

    let certs: [RegistrationCertificate] =
      if let verifierInfo = resolvedRequest.request.verifierInfo {
        try extractRegistrationCertificates(
          verifierInfo: verifierInfo,
          trustAnchors: registrationTrustAnchors,
        )
      } else {
        []
      }

    return try Self.requestData(
      from: resolvedRequest.request,
      registrationCertificates: certs,
    )
  }

  private func generateKey() throws -> (SecKey, WebKeySet.Key) {
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
    return (secKey, webKey)
  }

  private func validateAccessCertificates(
    certificateChain: [Base64Certificate],
    trustAnchors: [SecCertificate],
  ) -> Bool {
    (try? CertificateValidator.validate(base64CertChain: certificateChain, with: trustAnchors))
      != nil
  }

  private func extractRegistrationCertificates(
    verifierInfo: [VerifierInfo],
    trustAnchors: [SecCertificate],
  ) throws -> [RegistrationCertificate] {
    let verifierData = verifierInfo.compactMap { verifier in
      switch VerifierInfoFormat(rawValue: verifier.format) {
        case .registrationCert, .jwt:
          return verifier.data.string

        case nil:
          return nil
      }
    }

    return try verifierData.compactMap { data in
      try JwtUtil.parseJws(
        from: data,
        validateCertChain: { certChain in
          try CertificateValidator.validate(
            certChain: certChain,
            with: trustAnchors,
          )
        },
      )
    }
  }

  static func requestData(
    from data: ResolvedRequestData.VpTokenData,
    registrationCertificates: [RegistrationCertificate],
  ) throws
    -> PresentationRequestData
  {
    guard case let .byDigitalCredentialsQuery(dcql) = data.presentationQuery else {
      throw PresentationError.unsupportedQuery
    }

    let responseUrl: URL
    switch data.responseMode {
      case .directPost(let url), .directPostJWT(let url):
        responseUrl = url

      default:
        throw PresentationError.unsupportedResponseMode
    }

    return PresentationRequestData(
      credentialQueries: credentialQueries(from: dcql),
      responseUrl: responseUrl,
      clientId: data.client.id.clientId,
      nonce: data.nonce,
      state: data.state,
      encryption: try data.responseEncryptionSpecification.map { try Self.cryptoSpec(from: $0) },
      registrationCertificates: registrationCertificates,
      legalName: data.client.legalName,
    )
  }

  private static func cryptoSpec(
    from specification: ResponseEncryptionSpecification
  ) throws
    -> CryptoSpec
  {
    guard let key = specification.clientKey.keys.first,
      let algorithm = WalletJoseKeyManagementAlgorithm(
        rawValue: specification.responseEncryptionAlg.name
      ),
      let method = WalletJoseContentEncryptionAlgorithm(
        rawValue: specification.responseEncryptionEnc.name
      )
    else {
      throw PresentationError.resolutionFailed("Unsupported response encryption specification")
    }

    let jwk = try JSONDecoder().decode(WalletJoseJWK.self, from: JSONEncoder().encode(key))
    return CryptoSpec(key: jwk, enc: method, alg: algorithm)
  }

  static func credentialQueries(from dcql: DCQL) -> [CredentialQuery] {
    dcql.credentials.map { credential in
      let claimPaths =
        credential.claims?
        .map { claim in
          CredentialInterfaces.ClaimPath(
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
        format: credential.format.format,
        claimPaths: Set(claimPaths),
        required: isRequired(credential.id, in: dcql.credentialSets),
        vctValues: Set(credential.meta["vct_values"].arrayValue.compactMap(\.string)),
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
