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
    let url = baseUrl ?? #URL("https://wallet.sandbox.digg.se/api")
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

  private func initSession() async throws -> String {
    let deviceKey = try CryptoKeyStore.shared.getOrCreateKey(withTag: .deviceKey)

    guard let keyId = try? deviceKey.toJWK().parameters["kid"] else {
      throw SessionError.noKeyId
    }

    let nonce = try await getChallenge(keyId: keyId)
    let token = try await validateChallenge(key: deviceKey, nonce: nonce)

    self.token = token
    return token
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

  private func validateChallenge(key: SecKey, nonce: String) async throws -> String {
    let jwt = try JWTUtil.createJWT(with: key, payload: ["nonce": nonce])
    let input = Operations.ValidateChallenge.Input(body: .json(.init(signedJwt: jwt)))
    let response = try await client.validateChallenge(input)

    guard
      case let .ok(payload) = response,
      let accountId = try payload.body.json.accountId
    else {
      throw SessionError.failedChallenge
    }

    return accountId
  }
}
