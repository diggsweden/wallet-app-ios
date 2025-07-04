import Foundation
import SiopOpenID4VP

@Observable
class PresentationViewModel {
  let data: ResolvedRequestData.VpTokenData
  let storedCredential = UserDefaults.standard.string(forKey: "credential")
  private let openId4VPService: OpenID4VPService?
  var matches: [Disclosure] = []
  var success: Bool = false

  init(data: ResolvedRequestData.VpTokenData) {
    self.data = data
    // TODO: Add dependency injection
    openId4VPService = try? OpenID4VPService()
  }

  func sendVpToken() async throws {
    guard let storedCredential else {
      return
    }
    let credential = try JSONDecoder().decode(Credential.self, from: Data(storedCredential.utf8))

    let header = credential.sdJwt
    let body = matches.map { match in
      match.base64
    }
    let parts = [header] + body
    let vpToken = parts.joined(separator: "~")

    let responseUrl: URL? =
      switch data.responseMode {
        case .directPost(let url), .directPostJWT(let url):
          url
        default:
          nil
      }

    guard let responseUrl else {
      return
    }

    //    let id =
    //      switch data.presentationQuery {
    //        case .byPresentationDefinition(let presentationDefinition):
    //          presentationDefinition.id
    //        case .byDigitalCredentialsQuery(let dCQL):
    //          dCQL.credentials.first?.id.value ?? ""
    //      }

    guard
      let key = try? KeychainManager.shared.getOrCreateKey(withTag: "wallet-dev"),
      let jwt = try? JWTUtil.createJWT(from: key, payload: ["vp_token": vpToken])
    else {
      return
    }

    let requestBody = "response=\(jwt)"

    let response = try await NetworkClient.shared.fetchData(
      responseUrl,
      method: .post,
      contentType: "application/x-www-form-urlencoded",
      body: requestBody
    )

    print("DONE")
  }

  func matchCredentials() throws {
    guard let storedCredential else {
      return
    }

    let credential = try JSONDecoder().decode(Credential.self, from: Data(storedCredential.utf8))

    let claimPaths: [String] =
      switch data.presentationQuery {
        case .byPresentationDefinition(let presentationDefinition):
          presentationDefinition.inputDescriptors.flatMap { descriptor in
            descriptor.constraints.fields.flatMap { fields in
              fields.paths.map { $0.replacing(/^\$\./, with: "") }
            }
          }
        case .byDigitalCredentialsQuery(let dCQL):
          dCQL.credentials.reduce(into: []) { result, query in
            guard let claims = query.claims else {
              return
            }

            let claimPaths = claims.map { query in
              query.path.value.map { $0.description }.joined(separator: ".")
            }

            result.append(contentsOf: claimPaths)
          }
      }

    matches = claimPaths.compactMap { credential.disclosures[$0] }
  }
}
