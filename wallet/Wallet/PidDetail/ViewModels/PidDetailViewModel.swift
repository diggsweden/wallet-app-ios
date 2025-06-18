import Foundation
//
//  PidDetailViewModel.swift
//  wallet
//
import OpenID4VCI

@MainActor
class PidDetailViewModel: ObservableObject {
  @Published var credentialOffer: CredentialOffer?
  @Published var accessToken: String? = "-"
  @Published var credential: CredentialResponseModel?
  @Published var preAuthCodeString: String?
  @Published var txCode: String?
  @Published var decodedGrants: [String] = []

  let openId4VCIClientId = "wallet-dev"
  let authFlowRedirectionUrlString = "eudi-wallet://auth"

  func fetch(url: String) async {
    do {
      let resolver = CredentialOfferRequestResolver()
      let result = await resolver.resolve(source: try .init(urlString: url))

      switch result {
        case .success(let data):
          print("worked")
          print(data)
          credentialOffer = data
          print("credential Offer updated")
        case .failure(let error):
          print("error: \(error)")
      }
    } catch {
      print("Failed to create source: \(error)")
    }
  }

  func issuer() async {
    do {
      guard
        let credentialOffer,
        let redirectionUrl = URL(string: authFlowRedirectionUrlString)
      else {
        throw NSError(domain: "MissingOfferOrRedirectionUrl", code: 1, userInfo: nil)
      }

      if let grants = credentialOffer.grants, case .preAuthorizedCode(let preAuthCode) = grants {
        preAuthCodeString = preAuthCode.preAuthorizedCode
        txCode = String(describing: dump(preAuthCode.txCode))
        print(preAuthCode)
      }

      let configOpenId4 = OpenId4VCIConfig(
        clientId: openId4VCIClientId,
        authFlowRedirectionURI: redirectionUrl
      )

      let issuer = try await Issuer(
        authorizationServerMetadata: credentialOffer
          .authorizationServerMetadata,
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

      switch issuer {
        case .success:
          try accessToken = issuer.get().accessToken?.accessToken
        case .failure(let error):
          throw error
      }
    } catch {
      print("Failed to create Issuer: \(error)")
    }
  }

  func fetchCredential() async {
    guard let url = URL(string: "https://wallet.sandbox.digg.se/credential") else {
      return
    }

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
      guard let accessToken else {
        throw NSError(domain: "MissingAccessToken", code: 1, userInfo: nil)
      }

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

      let credentialResponse = try JSONDecoder()
        .decode(CredentialResponseModel.self, from: data)
      credential = credentialResponse
      parseCredential(credentialResponse)
    } catch {
      print("Error fetching data: \(error)")
    }
  }

  func parseCredential(_ credentialResponse: CredentialResponseModel) {
    var grants: [String] = []

    let parts = credentialResponse.credential.components(separatedBy: "~")

    for (index, part) in parts.enumerated() where index != 0 {
      guard let decodedString = part.decodeFromBase64() else {
        print("Failed decoding base64 string")
        continue
      }

      grants.append(decodedString)
    }

    decodedGrants = grants
  }
}
