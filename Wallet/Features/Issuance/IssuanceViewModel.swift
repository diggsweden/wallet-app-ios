import Foundation
import OpenID4VCI

// TODO: Proper error handling
struct GenericError: Error {
  let message: String
}

@MainActor
class IssuanceViewModel: ObservableObject {
  let credentialOfferUri: String
  let openId4VCIClient = Client(public: "wallet-dev")
  let authFlowRedirectionUrlString = "eudi-wallet://auth"
  private(set) var claimsMetadata: [String: Claim] = [:]
  @Published var issuerMetadata: CredentialIssuerMetadata?
  @Published var accessToken: String?
  @Published var pidClaims: [PidClaim]?

  init(credentialOfferUri: String) {
    self.credentialOfferUri = credentialOfferUri
  }

  func fetchMetadata() async {
    do {
      let credentialOffer = try await fetchCredentialOffer(with: credentialOfferUri)
      let newAccessToken = try await fetchAccessToken(with: credentialOffer)

      claimsMetadata = getClaimsMetadata(from: credentialOffer)
      issuerMetadata = credentialOffer.credentialIssuerMetadata
      accessToken = newAccessToken
    } catch {
      print("Error: \(error)")
    }
  }

  func fetchCredential(_ accessToken: String, url: URL) async {
    let requestModel = CredentialRequestModel(
      format: "vc+sd-jwt",
      vct: "urn:eu.europa.ec.eudi:pid:1",
      proof: Proof(
        proof_type: "jwt",
        jwt:
          "eyJ0eXAiOiJvcGVuaWQ0dmNpLXByb29mK2p3dCIsImFsZyI6IkVTMjU2IiwiandrIjp7Imt0eSI6IkVDIiwiY3J2IjoiUC0yNTYiLCJ4IjoiRHN4S1BwaUVseG9UYUJZcFN5QVdrdWFxUmxfbnpGNUFkZTBwM0FlOHg3VSIsInkiOiIxMUdtQVpOY0dtUGlXQWg5M20zNUkweUptX2V1VE5mcFVUbGxHN2F5SHlvIn19.eyJhdWQiOiJodHRwczovL3dhbGxldC5zYW5kYm94LmRpZ2cuc2UiLCJub25jZSI6IjZRX0x1bnRXZkdkZ1BoNjBMWkY2S2kxWHhXUkhMSTdJOXdpeXBVNkpRcGciLCJpYXQiOjE3NDY1MTQ0NzV9.TAwlcDkYFJgkCiP8_mbJ6yBrwdgXEiYe23RBdM5TSQUTa04eqY4nMQ5Igd9wLchToovLgZGpYO62d2y7wlcf4g"
      )
    )

    do {
      let response: CredentialResponseModel = try await NetworkClient.shared.fetch(
        url,
        method: .post,
        token: accessToken,
        body: requestModel
      )
      // TODO: Store credential in e.g. UserDefaults
      pidClaims = parseClaims(from: response.credential)
    } catch {
      print("Error fetching data: \(error)")
    }
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

  private func fetchCredentialOffer(with url: String) async throws -> CredentialOffer {
    let resolver = CredentialOfferRequestResolver()
    let result = await resolver.resolve(source: try .init(urlString: url), policy: .ignoreSigned)
    return try result.get()
  }

  private func fetchAccessToken(with credentialOffer: CredentialOffer) async throws -> String {
    guard let redirectionUrl = URL(string: authFlowRedirectionUrlString) else {
      throw GenericError(message: "Invalid redirection URL")
    }

    guard
      case let .preAuthorizedCode(preAuthCode)? = credentialOffer.grants,
      let preAuthCodeString = preAuthCode.preAuthorizedCode,
      let txCode = preAuthCode.txCode
    else {
      throw GenericError(message: "Missing pre-auth code")
    }

    let configOpenId4 = OpenId4VCIConfig(
      client: openId4VCIClient,
      authFlowRedirectionURI: redirectionUrl
    )

    let issuer = try await Issuer(
      authorizationServerMetadata: credentialOffer.authorizationServerMetadata,
      issuerMetadata: credentialOffer.credentialIssuerMetadata,
      config: configOpenId4
    )
    .authorizeWithPreAuthorizationCode(
      credentialOffer: credentialOffer,
      authorizationCode: IssuanceAuthorization(
        preAuthorizationCode: preAuthCodeString,
        txCode: txCode
      ),
      client: openId4VCIClient,
      transactionCode: "012345"
    )

    return try issuer.get().accessToken.accessToken
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
        result[claim.path.description] = claim
      }
  }
}
