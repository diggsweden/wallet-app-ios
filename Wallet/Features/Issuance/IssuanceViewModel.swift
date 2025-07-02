import Crypto
import Foundation
import JOSESwift
import OpenID4VCI

enum CredentialFlowState {
  case initial
  case issuerFetched(offer: CredentialOffer)
  case authorized(request: AuthorizedRequest)
  case credentialFetched(claims: [PidClaim])
  //  case error(Error)
}

@MainActor
@Observable
class IssuanceViewModel {
  let credentialOfferUri: String
  private let privateKey: P256.Signing.PrivateKey
  let openId4VCIClient = Client(public: "wallet-dev")
  private(set) var claimsMetadata: [String: Claim] = [:]
  private var issuer: Issuer?
  var issuerMetadata: CredentialIssuerMetadata?
  var state: CredentialFlowState = .initial
  var authorizationCode: String = ""

  init(credentialOfferUri: String) {
    self.credentialOfferUri = credentialOfferUri
    // TODO: Store private key instead of recreating it every time
    privateKey = P256.Signing.PrivateKey()
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
        throw GenericError(message: "Missing pre-auth code")
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
      )
    else {
      return
    }

    do {
      let result =
        try await issuer.requestCredential(
          request: request,
          bindingKeys: [createBindingKey()],
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
        print("Could not get credential")
        return
      }

      let pidClaims = parseClaims(from: credentialString)
      state = .credentialFetched(claims: pidClaims)
    } catch {
      print("Error fetching data: \(error)")
    }
  }

  private func createBindingKey() throws -> BindingKey {
    let (x, y) = try privateKey.publicKey.getXYCoordinates()

    let jwk = ECPublicKey(
      crv: .P256,
      x: x.base64URLEncodedString(),
      y: y.base64URLEncodedString()
    )

    return .jwk(
      algorithm: JWSAlgorithm(.ES256),
      jwk: jwk,
      privateKey: .custom(DiggSigner(privateKey)),
      issuer: openId4VCIClient.id
    )
  }

  private func parseClaims(from credential: String) -> [PidClaim] {
    let parts = credential.components(separatedBy: "~")
    return parts.dropFirst()
      .compactMap { part in
        guard
          let decodedData = Data(base64Encoded: part.addBase64Padding()),
          let parsedClaim = try? JSONDecoder().decode([String].self, from: decodedData),
          parsedClaim.count == 3
        else {
          return nil
        }

        let claimId = parsedClaim[1]
        let claimValue = parsedClaim[2]

        guard let claim = claimsMetadata[claimId] else {
          return nil
        }

        return PidClaim(claim: claim, value: claimValue)
      }
  }

  private func createIssuer(from credentialOffer: CredentialOffer) async throws -> Issuer {
    guard let redirectionUrl = URL(string: "eudi-wallet://auth") else {
      throw GenericError(message: "Invalid redirection URL")
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
