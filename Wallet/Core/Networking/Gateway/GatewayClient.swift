import Foundation
import JOSESwift
import OpenAPIRuntime
import OpenAPIURLSession
import WalletMacrosClient

struct GatewayClient {
  let client: Client

  init(baseUrl: URL = #URL("https://wallet.sandbox.digg.se/api")) {
    client = Client(
      serverURL: baseUrl,
      transport: URLSessionTransport(),
      middlewares: [AuthenticationMiddleware()]
    )
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
