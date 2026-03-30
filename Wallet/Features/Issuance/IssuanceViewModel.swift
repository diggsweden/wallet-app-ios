// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import AuthenticationServices
import Crypto
import Foundation
import JSONWebAlgorithms
import JSONWebKey
import OpenID4VCI
import WalletMacros
import eudi_lib_sdjwt_swift

enum IssuanceState {
  case initial
  case issuerFetched(offer: CredentialOffer)
  case authorized(request: AuthorizedRequest)
  case credentialFetched(credential: (SavedCredential, [ClaimUiModel]))
}

@MainActor
@Observable
class IssuanceViewModel {
  private let credentialOfferUri: String
  private(set) var claimsMetadata: [String: String] = [:]
  private var issuer: Issuer?
  private var credentialOffer: CredentialOffer?
  private let openId4VciUtil = OpenId4VciUtil()
  private var oauth = OauthCoordinator()
  private let jwtUtil = JwtUtil()
  private let gatewayApiClient: GatewayApi
  var issuerDisplayData: IssuerDisplay?
  var state: IssuanceState = .initial
  var error: ErrorEvent? = nil

  init(credentialOfferUri: String, gatewayApiClient: GatewayApi) {
    self.credentialOfferUri = credentialOfferUri
    self.gatewayApiClient = gatewayApiClient
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
    let payload: JwtProofPayload
    let keyAttestation: String?
    if let nonceURL = await issuer.issuerMetadata.nonceEndpoint?.url {
      let nonce = try await openId4VciUtil.fetchNonce(url: nonceURL)
      keyAttestation = try await gatewayApiClient.getWalletUnitAttestation(nonce: nonce)
      payload = JwtProofPayload(nonce: nonce, aud: aud)
    } else {
      keyAttestation = nil
      payload = JwtProofPayload(nonce: nil, aud: aud)
    }

    return try jwtUtil.signJwt(
      with: SigningKeyStore.getOrCreateKey(withTag: .walletKey),
      payload: payload,
      header: KeyAttestationHeader(keyAttestation: keyAttestation)
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
    var jwk = key.publicKey.jwkRepresentation
    jwk.algorithm = KeyManagementAlgorithm.ecdhES.rawValue
    let enc: ContentEncryptionAlgorithm = .a128GCM
    let credentialRequest = CredentialRequest(
      credentialConfigurationId: configId,
      credentialResponseEncryption: CredentialResponseEncryptionDTO(
        jwk: jwk,
        enc: enc.rawValue
      ),
      proofs: JwtProofType(jwt: [jwtProof])
    )

    return try await openId4VciUtil.fetchCredential(
      url: url,
      token: accessToken,
      credentialRequest: credentialRequest,
      requestEncryption: requestEncryption,
      responseDecryption: CryptoSpec(
        key: key.jwkRepresentation,
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
      proofs: JwtProofType(jwt: [jwtProof])
    )

    return try await openId4VciUtil.fetchCredential(
      url: url,
      token: accessToken,
      credentialRequest: credentialRequest
    )
  }

  private func parseCredential(
    _ credential: String,
    issuer: Display?
  ) throws -> (SavedCredential, [ClaimUiModel]) {
    let sdJwt = try CompactParser().getSignedSdJwt(serialisedString: credential)
    let claims =
      try sdJwt
      .toClaimUiModels(displayNames: claimsMetadata)

    let issuerDisplay = IssuerDisplay(
      name: issuer?.name ?? "",
      info: issuer?.description,
      imageUrl: issuer?.logo?.uri
    )

    return (
      SavedCredential(
        issuer: issuerDisplay,
        compactSerialized: credential,
        claimDisplayNames: claimsMetadata,
        claimsCount: claims.count,
      ), claims
    )
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

  private func getClaimsMetadata(from credentialOffer: CredentialOffer) -> [String: String] {
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
      .reduce(into: [String: String]()) { result, claim in
        let claimPath = claim.path.value
          .map { $0.description }
          .joined(separator: ".")
        let displayName = claim.display?.first?.name

        result[claimPath] = displayName
      }
  }
}
