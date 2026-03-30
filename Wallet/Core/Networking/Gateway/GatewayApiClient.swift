// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import JSONWebKey
import OpenAPIRuntime
import OpenAPIURLSession
import WalletMacros

protocol GatewayApi: Sendable {
  func createAccount(
    personalIdentityNumber: String,
    emailAddress: String,
    telephoneNumber: String?,
    jwk: JWK,
  ) async throws -> String

  func getWalletUnitAttestation(nonce: String) async throws -> String
}

struct GatewayApiClient: GatewayApi {
  let client: Client

  init(sessionManager: SessionManager, baseUrl: URL? = nil) {
    let url = baseUrl ?? AppConfig.apiBaseUrl
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
    jwk: JWK,
  ) async throws -> String {
    let jwkDto = try JwkDtoMapper.makeDto(from: jwk)
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
