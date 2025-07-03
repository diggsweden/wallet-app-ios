import Crypto
import Foundation
import JOSESwift
import OpenID4VCI

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
  let openId4VCIClient = Client(public: "wallet-dev")
  private(set) var claimsMetadata: [String: Claim] = [:]
  private var issuer: Issuer?
  var issuerMetadata: CredentialIssuerMetadata?
  var state: IssuanceState = .initial
  var authorizationCode: String = ""

  init(credentialOfferUri: String) {
    self.credentialOfferUri = credentialOfferUri
  }

  func fetchIssuer() async {
    do {
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
        throw AppError(message: "Missing pre-auth code")
      }

      let result = try await issuer.authorizeWithPreAuthorizationCode(
        credentialOffer: credentialOffer,
        authorizationCode: IssuanceAuthorization(
          preAuthorizationCode: preAuthCodeString,
          txCode: txCode
        ),
        client: openId4VCIClient,
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
      let configId = try? CredentialConfigurationIdentifier(
        value: "eu.europa.ec.eudi.pid_vc_sd_jwt"
      ),
      let key = try? KeychainManager.shared.getOrCreateKey(withTag: Constants.bindingKeyTag)
    else {
      return
    }

    do {
      let result =
        try await issuer.requestCredential(
          request: request,
          bindingKeys: [createBindingKey(from: key)],
          requestPayload: .configurationBased(
            credentialConfigurationIdentifier: configId
          )
        ) {
          Issuer.createResponseEncryptionSpec($0)
        }
        .get()

      guard
        case let .success(response) = result,
        let issuedCredential = response.credentialResponses.first,
        case let .issued(_, credential, _, _) = issuedCredential,
        case let .json(json) = credential,
        json.type == .array,
        let credentialString = json.first?.1["credential"].stringValue
      else {
        throw AppError(message: "Failed issuing credential")
      }

      let display = await issuer.issuerMetadata.display.first
      let parsedCredential = try parseCredential(credentialString, issuer: display)

      state = .credentialFetched(credential: parsedCredential)
    } catch {
      print("Error fetching credential: \(error)")
    }
  }

  func saveCredential(_ credential: Credential) {
    guard let json = try? JSONEncoder().encode(credential) else {
      return
    }

    let jsonString = String(data: json, encoding: .utf8)

    UserDefaults.standard.set(jsonString, forKey: "credential")
  }

  private func createBindingKey(from secKey: SecKey) throws -> BindingKey {
    return .jwk(
      algorithm: JWSAlgorithm(.ES256),
      jwk: try secKey.toJWK(),
      privateKey: .secKey(secKey),
      issuer: openId4VCIClient.id
    )
  }

  private func parseCredential(_ credential: String, issuer: Display?) throws -> Credential {
    let parts = credential.components(separatedBy: "~")

    guard let sdJwt = parts.first else {
      throw AppError(message: "Failed to parse credential")
    }

    let disclosures: [String: Disclosure] = parts.dropFirst()
      .reduce(into: [:]) { result, part in
        guard
          let data = JWTUtil.base64UrlDecode(part),
          let parsedClaim = try? JSONDecoder().decode([String].self, from: data),
          parsedClaim.count == 3
        else {
          return
        }
        let claimId = parsedClaim[1]
        let claimValue = parsedClaim[2]

        guard let claim = claimsMetadata[claimId] else {
          return
        }

        return result[claimId] = Disclosure(base64: part, claim: claim, value: claimValue)
      }

    return Credential(issuer: issuer, sdJwt: sdJwt, disclosures: disclosures)
  }

  private func createIssuer(from credentialOffer: CredentialOffer) async throws -> Issuer {
    guard let redirectionUrl = URL(string: "eudi-wallet://auth") else {
      throw AppError(message: "Invalid redirection URL")
    }

    return try Issuer(
      authorizationServerMetadata: credentialOffer.authorizationServerMetadata,
      issuerMetadata: credentialOffer.credentialIssuerMetadata,
      config: OpenId4VCIConfig(
        client: openId4VCIClient,
        authFlowRedirectionURI: redirectionUrl
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
            return config.claims
          case .msoMdoc(let config):
            return config.claims
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
