import Foundation
import JOSESwift
import OpenAPIRuntime
import OpenAPIURLSession
import WalletMacrosClient

struct GatewayClient {
  let client: Client

  init(baseUrl: URL? = nil) {
    let url = baseUrl ?? #URL("https://wallet.sandbox.digg.se/api")
    client = Client(
      serverURL: url,
      transport: URLSessionTransport(),
      middlewares: [AuthenticationMiddleware()]
    )
  }

  public func createAccount(
    personalIdentityNumber: String,
    emailAddress: String,
    telephoneNumber: String?,
    jwk: ECPublicKey
  ) async throws -> String {
    let jwkDto = Components.Schemas.JwkDto(
      kty: jwk.keyType.rawValue,
      kid: jwk.parameters["kid"],
      crv: jwk.crv.rawValue,
      x: jwk.x,
      y: jwk.y,
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

  public func getWalletUnitAttestation(
    walletId: String,
    jwk: ECPublicKey
  ) async throws -> String {
    let jwkDto = Components.Schemas.JwkDto(
      kty: jwk.keyType.rawValue,
      crv: jwk.crv.rawValue,
      x: jwk.x,
      y: jwk.y
    )
    let bodyDto = Components.Schemas.CreateWuaDto(walletId: UUID().uuidString, jwk: jwkDto)
    let input = Operations.CreateWua.Input(body: .json(bodyDto))

    let response = try await client.createWua(input)
    guard
      case let .created(payload) = response,
      let jwt = try? payload.body.json.jwt
    else {
      throw HTTPError.invalidResponse
    }

    return jwt
  }
}
