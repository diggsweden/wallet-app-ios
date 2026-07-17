// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession
import WalletGatewayInterface

public struct GatewayApiClient: GatewayApi {
  let client: Client

  public init(sessionManager: SessionManager, apiKey: String, baseUrl: URL) {
    client = Client(
      serverURL: baseUrl,
      transport: URLSessionTransport(),
      middlewares: [AuthenticationMiddleware(sessionManager: sessionManager, apiKey: apiKey)],
    )
  }

  public func createAccount(publicKey: PublicKeyComponents) async throws -> String {
    let jwkDto = Components.Schemas.EcJwkRequest(
      kty: publicKey.kty,
      kid: publicKey.kid,
      crv: publicKey.crv,
      x: publicKey.x,
      y: publicKey.y,
    )
    let bodyDto = Components.Schemas.CreateAccountRequest(deviceKey: jwkDto)
    let input = Operations.CreateAccount.Input(body: .json(bodyDto))

    switch try await client.createAccount(input) {
      case .created(let payload):
        guard let accountId = try? payload.body.json.accountId else {
          throw GatewayError.undecodableResponseBody
        }
        return accountId

      case .unauthorized:
        throw GatewayError.unauthorized

      case .`default`(let status, let response):
        throw GatewayError.problem(ProblemDetails(status: status, response: response))
    }
  }

  public func addAccountWalletKey(key: PublicKeyComponents) async throws {
    let keyRequest = Components.Schemas.EcJwkRequest(
      kty: key.kty,
      kid: key.kid,
      crv: key.crv,
      x: key.x,
      y: key.y,
    )
    let input = Operations.AddAccountWalletKey.Input(body: .json(keyRequest))

    switch try await client.addAccountWalletKey(input) {
      case .created:
        break

      case .`default`(let status, let response):
        throw GatewayError.problem(ProblemDetails(status: status, response: response))
    }
  }

  public func getWalletUnitAttestation(nonce: String?) async throws -> String {
    let nonceQuery = Operations.CreateWua.Input.Query(nonce: nonce)
    let input = Operations.CreateWua.Input(query: nonceQuery)

    switch try await client.createWua(input) {
      case .created(let payload):
        guard let jwt = try? payload.body.json.jwt else {
          throw GatewayError.undecodableResponseBody
        }
        return jwt

      case .unauthorized:
        throw GatewayError.unauthorized

      case .`default`(let status, let response):
        throw GatewayError.problem(ProblemDetails(status: status, response: response))
    }
  }
}
