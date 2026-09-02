// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Jose
import OpenID4VCI
import OpenId4VCInterface
import WalletNetworking

public actor IssuanceSession: IssuanceFlow {
  private let config: IssuanceConfig
  private let dpopProofBuilder = DpopProofBuilder()
  private let credentialEndpointClient: CredentialEndpointClient
  private var credentialOffer: CredentialOffer?
  private var issuer: Issuer?
  private var preparedRequest: AuthorizationRequested?
  private var authorizedRequest: AuthorizedRequest?
  private var proof: String?

  public init(config: IssuanceConfig) {
    self.init(config: config, networkClient: URLSessionNetworkClient())
  }

  init(config: IssuanceConfig, networkClient: any NetworkClient) {
    self.config = config
    self.credentialEndpointClient = CredentialEndpointClient(networkClient: networkClient)
  }

  public func loadOffer(_ offerUri: String) async throws -> OfferedIssuance {
    let result = await CredentialOfferRequestResolver()
      .resolve(
        source: try .init(urlString: offerUri),
        policy: .ignoreSigned,
      )
    let offer = try result.get()
    let issuer = try createIssuer(from: offer)

    credentialOffer = offer
    self.issuer = issuer

    return OfferedIssuance(
      issuer: offer.credentialIssuerMetadata.display.first.map { display in
        OfferedIssuer(name: display.name, info: display.description, imageUrl: display.logo?.uri)
      }
    )
  }

  public func authorizationUrl() async throws -> URL {
    let (issuer, offer) = try loadedIssuer()
    let prepared = try await issuer.prepareAuthorizationRequest(credentialOffer: offer)
    preparedRequest = prepared
    return prepared.authorizationCodeURL.url
  }

  public func exchangeAuthorizationCode(callbackUrl: URL) async throws {
    let (issuer, offer) = try loadedIssuer()
    guard let preparedRequest else {
      throw IssuanceError.authRequestFailed
    }

    guard let code = callbackUrl.queryItemValue(for: "code") else {
      throw IssuanceError.invalidAuth
    }

    let issuerState = callbackUrl.queryItemValue(for: "state") ?? preparedRequest.state

    authorizedRequest = try await issuer.authorizeWithAuthorizationCode(
      serverState: issuerState,
      request: preparedRequest,
      authorizationCode: .init(value: code),
      grant: .authorizationCode(
        .init(
          issuerState: issuerState,
          authorizationServer: offer.credentialIssuerMetadata.authorizationServers?.first,
        )
      ),
    )
  }

  public func createProof(
    signer: any ProofSigner,
    attestations: any KeyAttestationProviding,
  ) async throws {
    let offer = try loadedOffer()
    let metadata = offer.credentialIssuerMetadata
    let credentialConfig = try offer.sdJwtVcConfiguration().configuration

    guard let proofTypeJwt = credentialConfig.proofTypesSupported?["jwt"] else {
      throw IssuanceError.credentialNotSupported
    }

    let nonce: String? =
      if let nonceUrl = metadata.nonceEndpoint?.url {
        try await credentialEndpointClient.fetchNonce(url: nonceUrl)
      } else {
        nil
      }

    let keyAttestation: String? =
      switch proofTypeJwt.keyAttestationRequirement {
        case .required, .requiredNoConstraints:
          try await attestations.keyAttestation(nonce: nonce)

        case .notRequired, nil:
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
    let offer = try loadedOffer()
    guard let authorizedRequest, let proof else {
      throw IssuanceError.authRequestFailed
    }

    let metadata = offer.credentialIssuerMetadata
    let (configId, credentialConfig) = try offer.sdJwtVcConfiguration()

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

    return try IssuedCredential(
      compactSdJwt: credential,
      configuration: credentialConfig,
      issuer: metadata.display.first,
      claimDisplayNames: offer.claimDisplayNames,
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

  private func loadedIssuer() throws -> (Issuer, CredentialOffer) {
    guard let issuer else {
      throw IssuanceError.issuerNotFound
    }

    return (issuer, try loadedOffer())
  }

  private func loadedOffer() throws -> CredentialOffer {
    guard let credentialOffer else {
      throw IssuanceError.issuerNotFound
    }

    return credentialOffer
  }
}
