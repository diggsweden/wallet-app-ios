// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

public protocol GatewayApi: Sendable {
  func createAccount(publicKey: PublicKeyComponents) async throws -> String

  func addAccountWalletKey(key: PublicKeyComponents) async throws

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

  public func createAccount(publicKey: PublicKeyComponents) async throws -> String {
    let pin = (0 ..< 12).map { _ in String(Int.random(in: 0 ... 9)) }.joined()
    let email = "\((0..<8).map { _ in String(Int.random(in: 0...9)) }.joined())@example.com"
    let jwkDto = Components.Schemas.KeyRequest(
      kty: publicKey.kty,
      kid: publicKey.kid,
      crv: publicKey.crv,
      x: publicKey.x,
      y: publicKey.y,
    )
    let bodyDto = Components.Schemas.CreateAccountRequest(
      personalIdentityNumber: pin,
      emailAdress: email,
      telephoneNumber: nil,
      deviceKey: jwkDto,
    )
    let input = Operations.CreateAccounts.Input(body: .json(bodyDto))
    let response = try await client.createAccounts(input)

    guard case let .created(payload) = response else {
      throw GatewayError.invalidResponse
    }

    return try payload.body.json.accountId
  }

  public func addAccountWalletKey(key: PublicKeyComponents) async throws {
    let keyRequest = Components.Schemas.KeyRequest(
      kty: key.kty,
      kid: key.kid,
      crv: key.crv,
      x: key.x,
      y: key.y,
    )
    let input = Operations.AddAccountWalletKey.Input(body: .json(keyRequest))
    let response = try await client.addAccountWalletKey(input)
    guard case .created = response else {
      throw GatewayError.invalidResponse
    }
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
