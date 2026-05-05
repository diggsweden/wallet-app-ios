// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import SwiftAccessMechanism

extension GatewayApiClient: BFFTransport {
  public func registerState(
    publicKey: JwkKey,
    overwrite: Bool,
    ttl: String?,
  ) async throws -> RegisterStateResponse {
    let jwkDto = Components.Schemas.EcPublicJwkDto(
      kty: publicKey.kty,
      crv: publicKey.crv,
      x: publicKey.x,
      y: publicKey.y,
      kid: publicKey.kid,
    )
    let body = Components.Schemas.RegisterStateRequestDto(
      publicKey: jwkDto,
      overwrite: overwrite,
      ttl: ttl,
    )
    let input = Operations.RegisterState.Input(body: .json(body))
    let response = try await client.registerState(input)
    guard case let .created(payload) = response else { throw GatewayError.invalidResponse }
    let dto = try payload.body.json
    return RegisterStateResponse(
      clientId: dto.clientId,
      devAuthorizationCode: dto.devAuthorizationCode,
    )
  }

  public func registerPin(request: BFFRequest) async throws -> Data {
    let input = Operations.RegisterPin.Input(body: .json(.init(jwt: request.outerRequestJws)))
    let response = try await client.registerPin(input)
    guard case let .created(payload) = response else { throw GatewayError.invalidResponse }
    return Data((try payload.body.json.jwt).utf8)
  }

  public func createSession(request: BFFRequest) async throws -> Data {
    let input = Operations.CreateHsmSession.Input(body: .json(.init(jwt: request.outerRequestJws)))
    let response = try await client.createHsmSession(input)
    guard case let .created(payload) = response else { throw GatewayError.invalidResponse }
    return Data((try payload.body.json.jwt).utf8)
  }

  public func createKey(request: BFFRequest) async throws -> Data {
    let input = Operations.CreateKey.Input(body: .json(.init(jwt: request.outerRequestJws)))
    let response = try await client.createKey(input)
    guard case let .created(payload) = response else { throw GatewayError.invalidResponse }
    return Data((try payload.body.json.jwt).utf8)
  }

  public func listKeys(request: BFFRequest) async throws -> Data {
    let input = Operations.ListKeys.Input(body: .json(.init(jwt: request.outerRequestJws)))
    let response = try await client.listKeys(input)
    guard case let .ok(payload) = response else { throw GatewayError.invalidResponse }
    return Data((try payload.body.json.jwt).utf8)
  }

  public func sign(request: BFFRequest) async throws -> Data {
    let input = Operations.Sign.Input(body: .json(.init(jwt: request.outerRequestJws)))
    let response = try await client.sign(input)
    guard case let .ok(payload) = response else { throw GatewayError.invalidResponse }
    return Data((try payload.body.json.jwt).utf8)
  }

  public func deleteKey(request: BFFRequest) async throws {
    let input = Operations.DeleteKey.Input(body: .json(.init(jwt: request.outerRequestJws)))
    let response = try await client.deleteKey(input)
    guard case .noContent = response else { throw GatewayError.invalidResponse }
  }
}
