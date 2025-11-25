import Foundation
import JOSESwift
import OpenAPIRuntime
import OpenAPIURLSession
import WalletMacrosClient

struct PublicJWK: Sendable {
  let kty: String
  let kid: String?
  let crv: String
  let x: String
  let y: String
}

protocol GatewayAPI: Sendable {
  func createAccount(
    personalIdentityNumber: String,
    emailAddress: String,
    telephoneNumber: String?,
    jwk: PublicJWK
  ) async throws -> String

  func getWalletUnitAttestation(
    walletId: String,
    jwk: PublicJWK
  ) async throws -> String
}

actor GatewayAPIClient: GatewayAPI {
  let client: Client

  init(baseUrl: URL? = nil, sessionManager: SessionManager) {
    let url = baseUrl ?? #URL("https://wallet.sandbox.digg.se/api")
    client = Client(
      serverURL: url,
      transport: URLSessionTransport(),
      middlewares: [AuthenticationMiddleware(sessionManager: sessionManager)]
    )
  }

  func createAccount(
    personalIdentityNumber: String,
    emailAddress: String,
    telephoneNumber: String?,
    jwk: PublicJWK
  ) async throws -> String {
    let jwkDto = Components.Schemas.JwkDto(
      kty: jwk.kty,
      kid: jwk.kid,
      crv: jwk.crv,
      x: jwk.x,
      y: jwk.y
    )
    let bodyDto = Components.Schemas.CreateAccountRequestDto(
      personalIdentityNumber: personalIdentityNumber,
      emailAdress: emailAddress,
      telephoneNumber: telephoneNumber,
      publicKey: jwkDto
    )
    let input = Operations.CreateAccount.Input(body: .json(bodyDto))

    let response = try await client.createAccount(input)
    guard
      case let .created(payload) = response,
      let accountId = try? payload.body.json.accountId
    else {
      throw HTTPError.invalidResponse
    }

    return accountId
  }

  func getWalletUnitAttestation(
    walletId: String,
    jwk: PublicJWK
  ) async throws -> String {
    let jwkDto = Components.Schemas.JwkDto(
      kty: jwk.kty,
      crv: jwk.crv,
      x: jwk.x,
      y: jwk.y
    )
    let bodyDto = Components.Schemas.CreateWuaDto(walletId: UUID().uuidString, jwk: jwkDto)
    let input = Operations.CreateWua1.Input(body: .json(bodyDto))

    let response = try await client.createWua1(input)
    guard
      case let .created(payload) = response,
      let jwt = try? payload.body.json.jwt
    else {
      throw HTTPError.invalidResponse
    }

    return jwt
  }
}
