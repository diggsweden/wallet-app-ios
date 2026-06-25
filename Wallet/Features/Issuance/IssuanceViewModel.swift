// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import AuthenticationServices
import CredentialInterfaces
import CryptoKit
import Foundation
import OpenID4VCI
import SwiftAccessMechanism
import WalletGatewayInterface
import WalletMacros
import eudi_lib_sdjwt_swift

@MainActor
@Observable
// swiftlint:disable:next type_body_length
class IssuanceViewModel {
  private let credentialOfferUri: String
  private let gatewayApiClient: GatewayApi & HSMTransport
  private let jwtUtil = JwtUtil()
  private let openId4VciUtil = OpenId4VciUtil()
  private let onSaveCredential: (SavedCredential) async throws -> Void

  private(set) var claimsMetadata: [String: String] = [:]
  private(set) var error: ErrorEvent?
  private(set) var issuerDisplayData: IssuerDisplay?
  private(set) var phase: IssuancePhase = .fetchingIssuer

  private var credentialOffer: CredentialOffer?
  private var issuer: Issuer?
  private var oauth = OauthCoordinator()

  init(
    credentialOfferUri: String,
    gatewayApiClient: any GatewayApi & HSMTransport,
    onSaveCredential: @escaping (SavedCredential) async throws -> Void
  ) {
    self.credentialOfferUri = credentialOfferUri
    self.gatewayApiClient = gatewayApiClient
    self.onSaveCredential = onSaveCredential
  }

  func start() async {
    phase = .fetchingIssuer
    do {
      let credentialOffer = try await fetchCredentialOffer(with: credentialOfferUri)
      self.credentialOffer = credentialOffer
      claimsMetadata = getClaimsMetadata(from: credentialOffer)
      issuer = try await createIssuer(from: credentialOffer)
      phase = .readyToAuthorize(credentialOffer)
    } catch {
      phase = .error(.start)
    }
  }

  func beginAuthorization(anchor: ASPresentationAnchor) async {
    guard case .readyToAuthorize(let offer) = phase else {
      return
    }

    phase = .authorizing
    do {
      guard let issuer else {
        throw IssuanceError.issuerNotFound
      }

      let preparedRequest = try await issuer.prepareAuthorizationRequest(
        credentialOffer: offer
      )

      let oAuthCallback = try await oauth.start(
        url: preparedRequest.authorizationCodeURL.url,
        callbackScheme: "wallet-app",
        anchor: anchor,
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

      phase = .readyToSign(authResponse)
    } catch {
      phase = .error(.authorize(offer))
    }
  }

  func createProof(with pin: String) async {
    guard case .readyToSign(let authRequest) = phase else {
      return
    }

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

      let proof = try await createJwtProof(
        issuerId: metadata.credentialIssuerIdentifier.url.absoluteString,
        keyAttestationRequired: keyAttestationRequired,
        nonceUrl: metadata.nonceEndpoint?.url,
        pin: pin,
      )

      phase = .readyToFetch(authRequest, proof: proof)
      await fetchCredential()
    } catch {
      phase = .error(.enterPin(authRequest))
    }
  }

  func fetchCredential() async {
    guard case .readyToFetch(let authRequest, let proof) = phase else {
      return
    }

    phase = .fetchingCredential
    do {
      guard let issuer else {
        throw IssuanceError.issuerNotFound
      }

      let metadata = await issuer.issuerMetadata

      guard
        let configId = credentialOffer?.credentialConfigurationIdentifiers.first,
        let supportedCredential = metadata.credentialsSupported[configId],
        case let .sdJwtVc(credentialConfig) = supportedCredential
      else {
        throw IssuanceError.credentialNotSupported
      }

      let credential = try await openId4VciUtil.fetchCredential(
        url: metadata.credentialEndpoint.url,
        token: authRequest.accessToken.accessToken,
        credentialRequest: CredentialRequest(
          credentialConfigurationId: configId.value,
          proofs: JwtProofType(jwt: [proof]),
        ),
        requestEncryption: metadata.credentialRequestEncryption.toCryptoSpec(),
      )

      let display = metadata.display.first
      let (parsedCredential, credentialUiModels) = try parseCredential(
        credential,
        credentialConfiguration: credentialConfig,
        issuer: display,
      )

      phase = .done(parsedCredential, credentialUiModels)
    } catch {
      phase = .error(.fetchCredential(authRequest, proof: proof))
    }
  }

  private func createJwtProof(
    issuerId: String,
    keyAttestationRequired: Bool,
    nonceUrl: URL?,
    pin: String,
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

    let (hsmClient, stateJws) = try await getHSMClient()
    _ = try await hsmClient.authenticate(
      password: PINStretch().stretch(input: Data(pin.utf8)),
      stateJws: stateJws,
    )
    let keys = try await hsmClient.listKeys(stateJws: stateJws)

    guard
      let key = keys.keyInfo.first,
      let keyId = key.kid
    else {
      throw IssuanceError.noHSMKey
    }

    let payload = JwtProofPayload(aud: issuerId, nonce: nonce)
    let signingInput = try jwtUtil.createSigningInput(
      payload: payload,
      header: KeyAttestationHeader(
        jwk: keyAttestationRequired ? nil : key.publicKey.toSecKey().jwk,
        keyAttestation: keyAttestation,
      ),
    )
    let response = try await hsmClient.sign(hsmKeyId: keyId, data: signingInput.data)

    return "\(signingInput.base64String).\(response.signature)"
  }

  private func getHSMClient() async throws -> (client: BFFHttpClient, stateJws: String?) {
    let stateJws = try await gatewayApiClient.getAccountSecurityEnvelopes()

    guard let config = HSMClientStore.load() else {
      throw IssuanceError.missingHSMConfig
    }

    let client = try BFFHttpClient.resume(
      transport: gatewayApiClient,
      clientId: config.clientId,
      privateKey: SecKeyStore.getOrCreateKey(withTag: .walletKey),
      serverParameters: config.serverParameters,
    )

    return (client, stateJws)
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
        issuedAt: .now,
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

  func saveCredential(_ credential: SavedCredential) async {
    do {
      try await onSaveCredential(credential)
    } catch {
      phase = .error(.saveCredential(credential))
    }
  }

  func retry(anchor: ASPresentationAnchor?) {
    guard case .error(let recovery) = phase else {
      return
    }

    Task {
      switch recovery {
        case .start:
          await start()

        case .authorize(let offer):
          guard let anchor else { return }
          phase = .readyToAuthorize(offer)
          await beginAuthorization(anchor: anchor)

        case .enterPin(let authRequest):
          phase = .readyToSign(authRequest)

        case .fetchCredential(let authRequest, let proof):
          phase = .readyToFetch(authRequest, proof: proof)
          await fetchCredential()

        case .saveCredential(let credential):
          await saveCredential(credential)
      }
    }
  }
}
