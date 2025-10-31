import Crypto
import Foundation
import JOSESwift
import OpenID4VCI
import WalletMacrosClient

enum IssuanceState {
  case initial
  case issuerFetched(offer: CredentialOffer)
  case authorized(request: AuthorizedRequest)
  case credentialFetched(credential: Credential)
  //  case error(Error)
}

@MainActor
@Observable
class IssuanceViewModel {
  let credentialOfferUri: String
  let keyTag: UUID
  let wua: String
  private(set) var claimsMetadata: [String: Claim] = [:]
  private var issuer: Issuer?
  var issuerMetadata: CredentialIssuerMetadata?
  var state: IssuanceState = .initial
  var authorizationCode: String = ""
  private var key: SecKey?
  private let openId4VciUtil = OpenID4VCIUtil()

  init(credentialOfferUri: String, keyTag: UUID, wua: String) {
    self.credentialOfferUri = credentialOfferUri
    self.keyTag = keyTag
    self.wua = wua
  }

  func fetchIssuer() async {
    do {
      key = try KeychainManager.shared.getOrCreateKey(withTag: keyTag.uuidString)
      let credentialOffer = try await fetchCredentialOffer(with: credentialOfferUri)
      claimsMetadata = getClaimsMetadata(from: credentialOffer)
      issuerMetadata = credentialOffer.credentialIssuerMetadata
      issuer = try await createIssuer(from: credentialOffer)
      state = .issuerFetched(offer: credentialOffer)
    } catch {
      print("Error: \(error)")
    }
  }

  func authorize(with input: String, credentialOffer: CredentialOffer) async {
    do {
      guard
        let issuer,
        case let .preAuthorizedCode(preAuthCode)? = credentialOffer.grants,
        let preAuthCodeString = preAuthCode.preAuthorizedCode,
        let txCode = preAuthCode.txCode
      else {
        throw AppError(reason: "Missing pre-auth code")
      }

      let result = try await issuer.authorizeWithPreAuthorizationCode(
        credentialOffer: credentialOffer,
        authorizationCode: IssuanceAuthorization(
          preAuthorizationCode: preAuthCodeString,
          txCode: txCode
        ),
        client: .init(public: "wallet-dev"),
        transactionCode: input
      )

      let authorizedRequest = try result.get()
      state = .authorized(request: authorizedRequest)
    } catch {
      print(error)
    }
  }

  func fetchCredential(_ request: AuthorizedRequest) async {
    guard
      let issuer,
      let configId = await issuer.issuerMetadata.credentialsSupported.keys.first(where: {
        $0.value.contains("jwt") && $0.value.contains("pid")
      }),
      let key
    else {
      return
    }

    do {
      let nonce =
        if let nonceEndpoint = await issuer.issuerMetadata.nonceEndpoint?.url {
          try await openId4VciUtil.fetchNonce(url: nonceEndpoint)
        } else {
          ""
        }

      let jwtProof = try JWTUtil.createJWT(
        with: key,
        headers: [
          "typ": "openid4vci-proof+jwt",
          "key_attestation": wua,
        ],
        payload: [
          "nonce": nonce,
          "aud": await issuer.issuerMetadata.credentialIssuerIdentifier.url.absoluteString,
        ],
      )

      //      let credentialRequest = CredentialRequest(
      //        credentialConfigurationId: configId.value,
      //        proofs: JWTProofType(jwt: [jwtProof])
      //      )

      let oldCredentialRequest = CredentialRequestOld(
        credentialConfigurationId: configId.value,
        proof: ProofOld(jwt: jwtProof, proofType: "jwt")
      )
      let credential = try await openId4VciUtil.fetchCredential(
        url: issuer.issuerMetadata.credentialEndpoint.url,
        token: request.accessToken.accessToken,
        credentialRequest: oldCredentialRequest
      )

      let display = await issuer.issuerMetadata.display.first
      let parsedCredential = try parseCredential(credential, issuer: display)

      state = .credentialFetched(credential: parsedCredential)
    } catch {
      print("Error fetching credential: \(error)")
    }
  }

  private func createBindingKey(from secKey: SecKey) throws -> BindingKey {
    return .jwk(
      algorithm: JWSAlgorithm(.ES256),
      jwk: try secKey.toJWK(),
      privateKey: .secKey(secKey),
      issuer: "wallet-dev"
    )
  }

  private func parseCredential(_ credential: String, issuer: Display?) throws -> Credential {
    let parts = credential.components(separatedBy: "~")

    guard let jwt = parts.first else {
      throw AppError(reason: "Failed to parse credential")
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
        let displayName = claimsMetadata[claimId]?.display?.first?.name

        return result[claimId] = Disclosure(
          base64: part,
          displayName: displayName ?? "",
          value: claimValue
        )
      }

    return Credential(issuer: issuerDisplay, sdJwt: jwt, disclosures: disclosures)
  }

  private func createIssuer(from credentialOffer: CredentialOffer) async throws -> Issuer {
    return try Issuer(
      authorizationServerMetadata: credentialOffer.authorizationServerMetadata,
      issuerMetadata: credentialOffer.credentialIssuerMetadata,
      config: OpenId4VCIConfig(
        client: .init(public: "wallet-dev"),
        authFlowRedirectionURI: #URL("eudi-wallet://auth")
      )
    )
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
