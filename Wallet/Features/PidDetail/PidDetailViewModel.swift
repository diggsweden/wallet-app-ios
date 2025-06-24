import Foundation
import OpenID4VCI

// TODO: Proper error handling
struct GenericError: Error {
  let message: String
}

struct PidClaim: Identifiable {
  let id = UUID()
  let claim: Claim
  // TODO: Parse value into correct format based on claim.value_type
  let value: String
}

@MainActor
class PidDetailViewModel: ObservableObject {
  let credentialOfferUri: String
  let openId4VCIClientId = "wallet-dev"
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
      var request = URLRequest(url: url)
      request.httpMethod = "POST"
      request.setValue(
        "Bearer \(accessToken)",
        forHTTPHeaderField: "Authorization"
      )
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      request.httpBody = try JSONEncoder().encode(requestModel)

      let (data, _) = try await URLSession.shared.data(for: request)
      if let jsonString = String(data: data, encoding: .utf8) {
        print("Raw JSON response:\n\(jsonString)")
      }

      let credentialResponse = try JSONDecoder().decode(CredentialResponseModel.self, from: data)
      // TODO: Store credential in e.g. UserDefaults
      pidClaims = parseClaims(from: credentialResponse.credential)
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
    let result = await resolver.resolve(source: try .init(urlString: url))
    return try result.get()
  }

  private func fetchAccessToken(with credentialOffer: CredentialOffer) async throws -> String {
    guard let redirectionUrl = URL(string: authFlowRedirectionUrlString) else {
      throw GenericError(message: "Invalid redirection URL")
    }

    guard
      case let .preAuthorizedCode(preAuthCode)? = credentialOffer.grants,
      let preAuthCodeString = preAuthCode.preAuthorizedCode
    else {
      throw GenericError(message: "Missing pre-auth code")
    }

    let configOpenId4 = OpenId4VCIConfig(
      clientId: openId4VCIClientId,
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
        txCode: TxCode(
          inputMode: .numeric,
          length: 6,
          description: "PIN"
        )
      ),
      clientId: "wallet-dev",
      transactionCode: "012345"
    )

    guard let accessToken = try issuer.get().accessToken?.accessToken else {
      throw GenericError(message: "Missing access token")
    }

    return accessToken
  }

  private func getClaimsMetadata(from credentialOffer: CredentialOffer) -> [String: Claim] {
    return credentialOffer.credentialConfigurationIdentifiers.reduce(
      into: [String: Claim]()
    ) { result, id in
      guard
        let supportedCredentials = credentialOffer.credentialIssuerMetadata.credentialsSupported[id]
      else {
        return
      }

      switch supportedCredentials {
        case .sdJwtVc(let config):
          result.merge(config.claims) { _, new in new }

        case .msoMdoc(let config):
          let claims = config.claims
            .flatMap { $0.value }
          result.merge(claims) { _, new in new }

        default:
          break
      }
    }
  }
}
