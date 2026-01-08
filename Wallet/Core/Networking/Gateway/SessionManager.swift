import Foundation
import HTTPTypes
import OpenAPIRuntime
import OpenAPIURLSession
import WalletMacrosClient

final actor SessionManager {
  private var token: String? = nil
  private var expirationDate: Date = .now
  let client: Client
  let accountIDProvider: AccountIDProvider

  init(baseUrl: URL? = nil, accountIDProvider: AccountIDProvider) {
    let url = baseUrl ?? AppConfig.apiBaseURL
    client = Client(
      serverURL: url,
      transport: URLSessionTransport(),
    )
    self.accountIDProvider = accountIDProvider
  }

  func getToken() async throws -> String {
    return if let token {
      token
    } else {
      try await initSession()
    }
  }

  func reset() {
    token = nil
  }

  private func initSession() async throws -> String {
    let deviceKey = try KeychainService.getOrCreateKey(withTag: .deviceKey)

    guard let keyId = try? deviceKey.toECPublicKey().parameters["kid"] else {
      throw SessionError.noKeyId
    }

    let nonce = try await getChallenge(keyId: keyId)
    let sessionToken = try await validateChallenge(key: deviceKey, keyId: keyId, nonce: nonce)

    self.token = sessionToken
    return sessionToken
  }

  private func getChallenge(keyId: String) async throws -> String {
    guard let accountID = await accountIDProvider.accountID() else {
      throw SessionError.noAccountID
    }

    let query = Operations.InitChallenge.Input.Query(accountId: accountID, keyId: keyId)
    let response = try await client.initChallenge(query: query)

    guard
      case let .ok(payload) = response,
      let nonce = try? payload.body.json.nonce
    else {
      throw SessionError.failedChallenge
    }

    return nonce
  }

  private func validateChallenge(key: SecKey, keyId: String, nonce: String) async throws -> String {
    struct SessionPayload: Codable {
      let nonce: String
    }

    let payload = SessionPayload(nonce: nonce)
    let jwt = try JWTUtil().signJWT(with: key, payload: payload, headers: ["kid": keyId])
    let input = Operations.ValidateChallenge.Input(body: .json(.init(signedJwt: jwt)))
    let response = try await client.validateChallenge(input)

    guard case let .ok(payload) = response else {
      throw SessionError.failedChallenge
    }

    return payload.headers.session
  }
}
