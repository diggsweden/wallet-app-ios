// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import JOSESwift
import OpenAPIRuntime
import OpenAPIURLSession
import WalletMacrosClient

protocol GatewayAPI: Sendable {
  func createAccount(
    personalIdentityNumber: String,
    emailAddress: String,
    telephoneNumber: String?,
    jwk: ECPublicKey,
    oidcSessionId: String,
  ) async throws -> String

  func getWalletUnitAttestation(nonce: String) async throws -> String
}

struct GatewayAPIClient: GatewayAPI {
  let client: Client

  init(baseUrl: URL? = nil, sessionManager: SessionManager) {
    let url = baseUrl ?? AppConfig.apiBaseURL
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
    jwk: ECPublicKey,
    oidcSessionId: String,
  ) async throws -> String {
    let jwkDto = Components.Schemas.JwkDto(
      kty: jwk.keyType.rawValue,
      kid: jwk.parameters["kid"],
      crv: jwk.crv.rawValue,
      x: jwk.x,
      y: jwk.y
    )
    let bodyDto = Components.Schemas.CreateAccountRequestDto(
      personalIdentityNumber: personalIdentityNumber,
      emailAdress: emailAddress,
      telephoneNumber: telephoneNumber,
      publicKey: jwkDto
    )
    let headers = Operations.CreateAccount.Input.Headers(session: oidcSessionId)
    let input = Operations.CreateAccount.Input(headers: headers, body: .json(bodyDto))

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
    nonce: String,
  ) async throws -> String {
    let nonceQuery = Operations.CreateWua.Input.Query(nonce: nonce)
    let input = Operations.CreateWua.Input(query: nonceQuery)

    let response = try await client.createWua(input)

    guard case let .created(payload) = response
    else {
      throw HTTPError.invalidResponse
    }

    return try payload.body.json.jwt
  }
}
