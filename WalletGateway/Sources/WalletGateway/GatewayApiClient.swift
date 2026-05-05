// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

public protocol GatewayApi: Sendable {
  func createAccount(
    personalIdentityNumber: String,
    emailAddress: String,
    telephoneNumber: String?,
    publicKey: PublicKeyComponents,
  ) async throws -> String

  func getWalletUnitAttestation(nonce: String?) async throws -> String
}

public struct GatewayApiClient: GatewayApi {
  let client: Client

  public init(sessionManager: SessionManager, apiKey: String, baseUrl: URL) {
    client = Client(
      serverURL: baseUrl,
      transport: URLSessionTransport(),
      middlewares: [AuthenticationMiddleware(sessionManager: sessionManager, apiKey: apiKey)],
    )
  }

  public func createAccount(
    personalIdentityNumber: String,
    emailAddress: String,
    telephoneNumber: String?,
    publicKey: PublicKeyComponents,
  ) async throws -> String {
    let jwkDto = Components.Schemas.KeyRequest(
      kty: publicKey.kty,
      kid: publicKey.kid,
      crv: publicKey.crv,
      x: publicKey.x,
      y: publicKey.y,
    )
    let bodyDto = Components.Schemas.CreateAccountRequest(
      personalIdentityNumber: personalIdentityNumber,
      emailAdress: emailAddress,
      telephoneNumber: telephoneNumber,
      deviceKey: jwkDto,
    )
    let input = Operations.CreateAccounts.Input(body: .json(bodyDto))
    let response = try await client.createAccounts(input)

    guard case let .created(payload) = response else {
      throw GatewayError.invalidResponse
    }

    return try payload.body.json.accountId
  }

  public func getWalletUnitAttestation(nonce: String?) async throws -> String {
    let nonceQuery = Operations.CreateWua.Input.Query(nonce: nonce)
    let input = Operations.CreateWua.Input(query: nonceQuery)
    let response = try await client.createWua(input)

    guard case let .created(payload) = response else {
      throw GatewayError.invalidResponse
    }

    return try payload.body.json.jwt
  }
}

public enum GatewayError: Error {
  case invalidResponse
}
