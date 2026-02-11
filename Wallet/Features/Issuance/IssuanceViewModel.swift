// SPDX-FileCopyrightText: 2026 diggsweden/wallet-app-ios
//
// SPDX-License-Identifier: EUPL-1.2

import AuthenticationServices
import Crypto
import Foundation
@preconcurrency import JOSESwift
import OpenID4VCI
import WalletMacrosClient

enum IssuanceState {
  case initial
  case issuerFetched(offer: CredentialOffer)
  case authorized(request: AuthorizedRequest)
  case credentialFetched(credential: Credential)
}

@MainActor
@Observable
class IssuanceViewModel {
  private let credentialOfferUri: String
  private(set) var claimsMetadata: [String: Claim] = [:]
  private var issuer: Issuer?
  private var credentialOffer: CredentialOffer?
  private let openId4VciUtil = OpenID4VCIUtil()
  private var oauth = OAuthCoordinator()
  private let jwtUtil = JWTUtil()
  private let gatewayAPICLient: GatewayAPI
  var issuerDisplayData: IssuerDisplay?
  var state: IssuanceState = .initial
  var error: ErrorEvent? = nil

  init(credentialOfferUri: String, gatewayAPIClient: GatewayAPI) {
    self.credentialOfferUri = credentialOfferUri
    self.gatewayAPICLient = gatewayAPIClient
  }

  func fetchIssuer() async {
    do {
      let credentialOffer = try await fetchCredentialOffer(with: credentialOfferUri)
      self.credentialOffer = credentialOffer
      claimsMetadata = getClaimsMetadata(from: credentialOffer)
      issuer = try await createIssuer(from: credentialOffer)
      state = .issuerFetched(offer: credentialOffer)
    } catch {
      self.error = error.toErrorEvent()
    }
  }

  func authorize(
    credentialOffer: CredentialOffer,
    authPresentationAnchor: ASPresentationAnchor
  ) async {
    do {
      guard let issuer else {
        throw IssuanceError.issuerNotFound
      }

      let prepared = try await issuer.prepareAuthorizationRequest(credentialOffer: credentialOffer)
        .get()

      guard case let .prepared(data) = prepared else {
        throw IssuanceError.authRequestFailed
      }

      let oAuthCallback = try await oauth.start(
        url: data.authorizationCodeURL.url,
        callbackScheme: "wallet-app",
        anchor: authPresentationAnchor
      )

      guard let code = oAuthCallback.queryItemValue(for: "code") else {
        throw IssuanceError.invalidAuth
      }

      let requestWithAuthCode =
        try await issuer.handleAuthorizationCode(
          request: prepared,
          authorizationCode: .init(authorizationCode: code)
        )
        .get()

      let issuanceState = data.state
      let authCodeUrl = await issuer.issuerMetadata.authorizationServers?.first

      let authResponse =
        try await issuer
        .authorizeWithAuthorizationCode(
          request: requestWithAuthCode,
          grant: .authorizationCode(
            .init(
              issuerState: issuanceState,
              authorizationServer: authCodeUrl,
            )
          )
        )
        .get()

      state = .authorized(request: authResponse)
      await fetchCredential(authResponse)
    } catch {
      self.error = error.toErrorEvent()
    }
  }

  func fetchCredential(_ authRequest: AuthorizedRequest) async {
    do {
      guard let issuer else {
        throw IssuanceError.issuerNotFound
      }

      guard
        let configId = credentialOffer?.credentialConfigurationIdentifiers.first,
        let supportedCredential = await issuer.issuerMetadata.credentialsSupported[configId],
        supportedCredential.proofTypesSupported?["jwt"] != nil
      else {
        throw IssuanceError.credentialNotSupported
      }

      let jwtProof = try await createProof(issuer)
      let requestEncryption = await issuer.issuerMetadata.credentialRequestEncryption.toCryptoSpec()
      let url = await issuer.issuerMetadata.credentialEndpoint.url
      let accessToken = authRequest.accessToken.accessToken

      let credential: String
      if let requestEncryption {
        credential = try await fetchEncryptedCredential(
          requestEncryption: requestEncryption,
          jwtProof: jwtProof,
          configId: configId.value,
          url: url,
          accessToken: accessToken
        )
      } else {
        credential = try await fetchUnencryptedCredential(
          jwtProof: jwtProof,
          configId: configId.value,
          url: url,
          accessToken: accessToken
        )
      }

      let display = await issuer.issuerMetadata.display.first
      let parsedCredential = try parseCredential(credential, issuer: display)

      state = .credentialFetched(credential: parsedCredential)
    } catch {
      self.error = error.toErrorEvent()
    }
  }

  private func createProof(_ issuer: Issuer) async throws -> String {
    let aud = await issuer.issuerMetadata.credentialIssuerIdentifier.url.absoluteString
    var headers: [String: Any] = ["typ": "openid4vci-proof+jwt"]

    let payload: JWTProofPayload
    if let nonceURL = await issuer.issuerMetadata.nonceEndpoint?.url {
      let nonce = try await openId4VciUtil.fetchNonce(url: nonceURL)
      let wua = try await gatewayAPICLient.getWalletUnitAttestation(nonce: nonce)

      headers["key_attestation"] = wua
      payload = JWTProofPayload(nonce: nonce, aud: aud)
    } else {
      payload = JWTProofPayload(nonce: nil, aud: aud)
    }

    return try jwtUtil.signJWT(
      with: KeychainService.getOrCreateKey(withTag: .walletKey),
      payload: payload,
      headers: headers,
      includeJWK: false
    )
  }

  private func fetchEncryptedCredential(
    requestEncryption: CryptoSpec,
    jwtProof: String,
    configId: String,
    url: URL,
    accessToken: String,
  ) async throws -> String {
    let key = P256.KeyAgreement.PrivateKey()
    let enc: ContentEncryptionAlgorithm = .A128GCM
    let credentialRequest = CredentialRequest(
      credentialConfigurationId: configId,
      credentialResponseEncryption: CredentialResponseEncryptionDTO(
        jwk: try key.publicKey.toECPublicKey(),
        enc: enc.rawValue
      ),
      proofs: JWTProofType(jwt: [jwtProof])
    )

    return try await openId4VciUtil.fetchCredential(
      url: url,
      token: accessToken,
      credentialRequest: credentialRequest,
      requestEncryption: requestEncryption,
      responseDecryption: CryptoSpec(
        key: try key.toECPrivateKey(),
        enc: enc
      )
    )
  }

  private func fetchUnencryptedCredential(
    jwtProof: String,
    configId: String,
    url: URL,
    accessToken: String
  ) async throws -> String {
    let credentialRequest = CredentialRequest(
      credentialConfigurationId: configId,
      proofs: JWTProofType(jwt: [jwtProof])
    )

    return try await openId4VciUtil.fetchCredential(
      url: url,
      token: accessToken,
      credentialRequest: credentialRequest
    )
  }

  private func parseCredential(_ credential: String, issuer: Display?) throws -> Credential {
    let parts = credential.components(separatedBy: "~")

    guard let jwt = parts.first else {
      throw IssuanceError.invalidCredential
    }

    let issuerDisplay = IssuerDisplay(
      name: issuer?.name ?? "",
      info: issuer?.description,
      imageUrl: issuer?.logo?.uri
    )

    let disclosures: [String: Disclosure] = parts.dropFirst()
      .reduce(into: [:]) { result, part in
        guard
          let data = JWTUtil.base64UrlDecode(part),
          let disclosure = try? JSONDecoder().decode([String].self, from: data),
          disclosure.count == 3
        else {
          return
        }
        let claimId = disclosure[1]
        let claimValue = disclosure[2]
        let displayName: String =
          claimsMetadata[claimId]?.display?.first?.name
          ?? claimId.replacingOccurrences(of: "_", with: " ").capitalized

        return result[claimId] = Disclosure(
          base64: part,
          displayName: displayName,
          value: claimValue
        )
      }

    return Credential(issuer: issuerDisplay, sdJwt: jwt, disclosures: disclosures)
  }

  private func createIssuer(from credentialOffer: CredentialOffer) async throws -> Issuer {
    let issuer = try Issuer(
      authorizationServerMetadata: credentialOffer.authorizationServerMetadata,
      issuerMetadata: credentialOffer.credentialIssuerMetadata,
      config: OpenId4VCIConfig(
        client: .init(public: "wallet-dev"),
        authFlowRedirectionURI: #URL("wallet-app://authorize")
      )
    )

    if let display = await issuer.issuerMetadata.display.first {
      issuerDisplayData = IssuerDisplay(
        name: display.name ?? "Okänd utfärdare",
        info: display.description,
        imageUrl: display.logo?.uri
      )
    }

    return issuer
  }

  private func fetchCredentialOffer(with url: String) async throws -> CredentialOffer {
    let resolver = CredentialOfferRequestResolver()
    let result = await resolver.resolve(source: try .init(urlString: url), policy: .ignoreSigned)
    return try result.get()
  }

  private func getClaimsMetadata(from credentialOffer: CredentialOffer) -> [String: Claim] {
    return credentialOffer.credentialConfigurationIdentifiers
      .compactMap { id in
        credentialOffer.credentialIssuerMetadata.credentialsSupported[id]
      }
      .flatMap { supportedCredential in
        switch supportedCredential {
          case .sdJwtVc(let config):
            return config.credentialMetadata?.claims ?? []
          case .msoMdoc(let config):
            return config.credentialMetadata?.claims ?? []
          default:
            return []
        }
      }
      .reduce(into: [String: Claim]()) { result, claim in
        let claimPath = claim.path.value
          .map { $0.description }
          .joined(separator: ".")
        result[claimPath] = claim
      }
  }
}
