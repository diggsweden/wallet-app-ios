// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import AuthenticationServices
import Foundation
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
  var error: ErrorEvent?

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
    authPresentationAnchor: ASPresentationAnchor,
  ) async {
    do {
      guard let issuer else {
        throw IssuanceError.issuerNotFound
      }

      let preparedRequest = try await issuer.prepareAuthorizationRequest(
        credentialOffer: credentialOffer
      )

      let oAuthCallback = try await oauth.start(
        url: preparedRequest.authorizationCodeURL.url,
        callbackScheme: "wallet-app",
        anchor: authPresentationAnchor,
      )

      guard let code = oAuthCallback.queryItemValue(for: "code") else {
        throw IssuanceError.invalidAuth
      }

      let authCodeReceived = try await issuer.handleAuthorizationCode(
        request: preparedRequest,
        authorizationCode: .init(authorizationCode: code),
      )

      let authorizationServer = await issuer.issuerMetadata.authorizationServers?.first
      let issuerState = oAuthCallback.queryItemValue(for: "state") ?? preparedRequest.state

      let authResponse =
        try await issuer
        .authorizeWithAuthorizationCode(
          request: authCodeReceived,
          preparedRequest: preparedRequest,
          grant: .authorizationCode(
            .init(
              issuerState: issuerState,
              authorizationServer: authorizationServer,
            )
          ),
        )

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

      let metadata = await issuer.issuerMetadata

      guard
        let configId = credentialOffer?.credentialConfigurationIdentifiers.first,
        let supportedCredential = metadata.credentialsSupported[configId],
        case let .sdJwtVc(credentialConfig) = supportedCredential,
        let proofTypeJwt = credentialConfig.proofTypesSupported?["jwt"]
      else {
        throw IssuanceError.credentialNotSupported
      }

      let keyAttestationRequired =
        switch proofTypeJwt.keyAttestationRequirement {
          case .required, .requiredNoConstraints: true
          default: false
        }

      let jwtProof = try await createProof(
        issuerId: metadata.credentialIssuerIdentifier.url.absoluteString,
        keyAttestationRequired: keyAttestationRequired,
        nonceUrl: metadata.nonceEndpoint?.url,
      )

      let credential = try await openId4VciUtil.fetchCredential(
        url: metadata.credentialEndpoint.url,
        token: authRequest.accessToken.accessToken,
        credentialRequest: CredentialRequest(
          credentialConfigurationId: configId.value,
          proofs: JwtProofType(jwt: [jwtProof]),
        ),
        requestEncryption: metadata.credentialRequestEncryption.toCryptoSpec(),
      )

      let display = metadata.display.first
      let parsedCredential = try parseCredential(
        credential,
        credentialConfiguration: credentialConfig,
        issuer: display,
      )

      state = .credentialFetched(credential: parsedCredential)
    } catch {
      self.error = error.toErrorEvent()
    }
  }

  private func createProof(
    issuerId: String,
    keyAttestationRequired: Bool,
    nonceUrl: URL?,
  ) async throws -> String {
    let nonce: String? =
      if let nonceUrl {
        try await openId4VciUtil.fetchNonce(url: nonceUrl)
      } else {
        nil
      }

    let keyAttestation: String? =
      if keyAttestationRequired {
        try await gatewayApiClient.getWalletUnitAttestation(nonce: nonce)
      } else {
        nil
      }

    let payload = JwtProofPayload(aud: issuerId, nonce: nonce)
    let key = try SigningKeyStore.getOrCreateKey(withTag: .walletKey)

    return try jwtUtil.signJwt(
      with: SigningKeyStore.getOrCreateKey(withTag: .walletKey),
      payload: payload,
      header: KeyAttestationHeader(
        jwk: keyAttestationRequired ? nil : key.publicKey.jwk,
        keyAttestation: keyAttestation,
      ),
    )
  }

  private func parseCredential(
    _ credential: String,
    credentialConfiguration: SdJwtVcFormat.CredentialConfiguration,
    issuer: Display?,
  ) throws -> (SavedCredential, [ClaimUiModel]) {
    let sdJwt = try CompactParser().getSignedSdJwt(serialisedString: credential)
    let displayName = credentialConfiguration.credentialMetadata?.display.first?.name
    let claims = try sdJwt.toClaimUiModels(displayNames: claimsMetadata)

    let issuerDisplay = IssuerDisplay(
      name: issuer?.name ?? "",
      info: issuer?.description,
      imageUrl: issuer?.logo?.uri,
    )

    return (
      SavedCredential(
        issuer: issuerDisplay,
        compactSerialized: credential,
        claimDisplayNames: claimsMetadata,
        claimsCount: claims.count,
        type: credentialConfiguration.vct ?? "",
        displayData: CredentialDisplayData(name: displayName),
      ), claims,
    )
  }

  private func createIssuer(from credentialOffer: CredentialOffer) async throws -> Issuer {
    let issuer = try Issuer(
      authorizationServerMetadata: credentialOffer.authorizationServerMetadata,
      issuerMetadata: credentialOffer.credentialIssuerMetadata,
      config: OpenId4VCIConfig(
        client: .init(public: "wallet-dev"),
        authFlowRedirectionURI: #URL("wallet-app://authorize"),
      ),
    )

    if let display = await issuer.issuerMetadata.display.first {
      issuerDisplayData = IssuerDisplay(
        name: display.name ?? "Okänd utfärdare",
        info: display.description,
        imageUrl: display.logo?.uri,
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
    credentialOffer.credentialConfigurationIdentifiers
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
          .map(\.description)
          .joined(separator: ".")
        let displayName = claim.display?.first?.name

        result[claimPath] = displayName
      }
  }
}
