// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import Foundation
import Jose
import OpenID4VCI
import OpenId4VCInterface
import SdJwtClaims
import WalletNetworking
import eudi_lib_sdjwt_swift

public actor IssuanceSession: IssuanceFlow {
  private let config: IssuanceConfig
  private let dpopProofBuilder = DpopProofBuilder()
  private let credentialEndpointClient = CredentialEndpointClient()
  private var credentialOffer: CredentialOffer?
  private var issuer: Issuer?
  private var claimDisplayNames: [String: String] = [:]
  private var preparedRequest: AuthorizationRequested?
  private var authorizedRequest: AuthorizedRequest?
  private var proof: String?

  public init(config: IssuanceConfig) {
    self.config = config
  }

  public func loadOffer(_ offerUri: String) async throws -> OfferedIssuance {
    let resolver = CredentialOfferRequestResolver()
    let result = await resolver.resolve(
      source: try .init(urlString: offerUri),
      policy: .ignoreSigned,
    )
    let offer = try result.get()
    let issuer = try createIssuer(from: offer)

    credentialOffer = offer
    self.issuer = issuer
    claimDisplayNames = Self.claimDisplayNames(from: offer)

    let display = await issuer.issuerMetadata.display.first
    return OfferedIssuance(
      issuer: display.map { display in
        OfferedIssuer(name: display.name, info: display.description, imageUrl: display.logo?.uri)
      },
      claimDisplayNames: claimDisplayNames,
    )
  }

  public func authorizationUrl() async throws -> URL {
    let (issuer, offer) = try loadedIssuer()
    let prepared = try await issuer.prepareAuthorizationRequest(credentialOffer: offer)
    preparedRequest = prepared
    return prepared.authorizationCodeURL.url
  }

  public func exchangeAuthorizationCode(callbackUrl: URL) async throws {
    let (issuer, _) = try loadedIssuer()
    guard let preparedRequest else {
      throw IssuanceError.authRequestFailed
    }

    guard let code = callbackUrl.queryItemValue(for: "code") else {
      throw IssuanceError.invalidAuth
    }

    let authorizationServer = await issuer.issuerMetadata.authorizationServers?.first
    let issuerState = callbackUrl.queryItemValue(for: "state") ?? preparedRequest.state

    authorizedRequest = try await issuer.authorizeWithAuthorizationCode(
      serverState: issuerState,
      request: preparedRequest,
      authorizationCode: .init(value: code),
      grant: .authorizationCode(
        .init(
          issuerState: issuerState,
          authorizationServer: authorizationServer,
        )
      ),
    )
  }

  public func createProof(
    signer: any ProofSigner,
    attestations: any KeyAttestationProviding,
  ) async throws {
    let (issuer, offer) = try loadedIssuer()
    let metadata = await issuer.issuerMetadata
    let (_, credentialConfig) = try Self.sdJwtVcConfiguration(metadata, offer: offer)

    guard let proofTypeJwt = credentialConfig.proofTypesSupported?["jwt"] else {
      throw IssuanceError.credentialNotSupported
    }

    let keyAttestationRequired =
      switch proofTypeJwt.keyAttestationRequirement {
        case .required, .requiredNoConstraints: true
        default: false
      }

    let nonce: String? =
      if let nonceUrl = metadata.nonceEndpoint?.url {
        try await credentialEndpointClient.fetchNonce(url: nonceUrl)
      } else {
        nil
      }

    let keyAttestation: String? =
      if keyAttestationRequired {
        try await attestations.keyAttestation(nonce: nonce)
      } else {
        nil
      }

    proof = try await Self.buildProof(
      issuerId: metadata.credentialIssuerIdentifier.url.absoluteString,
      nonce: nonce,
      keyAttestation: keyAttestation,
      signer: signer,
    )
  }

  public func fetchCredential() async throws -> OpenId4VCInterface.IssuedCredential {
    let (issuer, offer) = try loadedIssuer()
    guard let authorizedRequest, let proof else {
      throw IssuanceError.authRequestFailed
    }

    let metadata = await issuer.issuerMetadata
    let (configId, credentialConfig) = try Self.sdJwtVcConfiguration(metadata, offer: offer)

    let credential = try await credentialEndpointClient.fetchCredential(
      url: metadata.credentialEndpoint.url,
      authorization: authorizedRequest.accessToken.requestAuthorization(
        proofBuilder: dpopProofBuilder
      ),
      credentialRequest: CredentialRequest(
        credentialConfigurationId: configId.value,
        proofs: JwtProofType(jwt: [proof]),
      ),
      requestEncryption: metadata.credentialRequestEncryption.toCryptoSpec(),
    )

    return try parseCredential(
      credential,
      credentialConfiguration: credentialConfig,
      issuer: metadata.display.first,
    )
  }

  // The proof must be signed by the key in the *first* element of the WUA's
  // `attested_keys` claim, which the header names by its index — hence "0".
  // ETSI TS 119 472-3, CRED-REQ-4.6.1.2-07:
  // https://www.etsi.org/deliver/etsi_ts/119400_119499/11947203/01.01.01_60/ts_11947203v010101p.pdf
  static func buildProof(
    issuerId: String,
    nonce: String?,
    keyAttestation: String?,
    signer: any ProofSigner,
  ) async throws -> String {
    let attested = keyAttestation != nil
    let header = WalletKeyAttestationHeader(
      jwk: attested ? nil : try await signer.publicKey(),
      keyID: attested ? "0" : nil,
      keyAttestation: keyAttestation,
    )

    return try await JwtUtil.signJwt(
      payload: JwtProofPayload(aud: issuerId, nonce: nonce),
      header: header,
    ) { signingInput in
      try await signer.sign(signingInput)
    }
  }

  private func loadedIssuer() throws -> (Issuer, CredentialOffer) {
    guard let issuer, let credentialOffer else {
      throw IssuanceError.issuerNotFound
    }
    return (issuer, credentialOffer)
  }

  private func createIssuer(from credentialOffer: CredentialOffer) throws -> Issuer {
    let authorizationServerMetadata = credentialOffer.authorizationServerMetadata

    return try Issuer(
      authorizationServerMetadata: authorizationServerMetadata,
      issuerMetadata: credentialOffer.credentialIssuerMetadata,
      config: OpenId4VCIConfig(
        client: .init(public: config.clientId),
        authFlowRedirectionURI: config.redirectUri,
        requireDpop: authorizationServerMetadata.supportsDpop,
      ),
      dpopConstructor: dpopProofBuilder,
    )
  }

  private func parseCredential(
    _ credential: String,
    credentialConfiguration: SdJwtVcFormat.CredentialConfiguration,
    issuer: Display?,
  ) throws -> OpenId4VCInterface.IssuedCredential {
    let sdJwt = try CompactParser().getSignedSdJwt(serialisedString: credential)
    let displayName = credentialConfiguration.credentialMetadata?.display.first?.name
    let claims = try sdJwt.toClaimUiModels(displayNames: claimDisplayNames)

    let issuerDisplay = IssuerDisplay(
      name: issuer?.name ?? "",
      info: issuer?.description,
      imageUrl: issuer?.logo?.uri,
    )

    return IssuedCredential(
      credential: SavedCredential(
        issuer: issuerDisplay,
        compactSerialized: credential,
        claimDisplayNames: claimDisplayNames,
        claimsCount: claims.count,
        issuedAt: .now,
        type: credentialConfiguration.vct ?? "",
        displayData: CredentialDisplayData(name: displayName),
      ),
      claims: claims,
    )
  }

  private static func sdJwtVcConfiguration(
    _ metadata: CredentialIssuerMetadata,
    offer: CredentialOffer,
  ) throws -> (CredentialConfigurationIdentifier, SdJwtVcFormat.CredentialConfiguration) {
    guard
      let configId = offer.credentialConfigurationIdentifiers.first,
      let supportedCredential = metadata.credentialsSupported[configId],
      case let .sdJwtVc(credentialConfig) = supportedCredential
    else {
      throw IssuanceError.credentialNotSupported
    }

    return (configId, credentialConfig)
  }

  private static func claimDisplayNames(from credentialOffer: CredentialOffer) -> [String: String] {
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
