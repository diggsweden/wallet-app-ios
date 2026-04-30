// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import SwiftAccessMechanism

extension GatewayApiClient: BFFTransport {
  public func changePin(request: BFFRequest) async throws -> Data {
    let input = Operations.ChangePin.Input(
      body: .json(.init(jwt: request.outerRequestJws, clientId: request.clientId))
    )
    let response = try await client.changePin(input)

    guard case let .ok(payload) = response else {
      throw GatewayError.invalidResponse
    }

    guard let jwt = try? payload.body.json.jwt else {
      throw GatewayError.undecodableResponseBody
    }
    return Data(jwt.utf8)
  }

  public func registerState(
    publicKey: JwkKey,
    overwrite: Bool,
    ttl: String?,
  ) async throws -> RegisterStateResponse {
    guard let kid = publicKey.kid else {
      throw GatewayError.missingKeyIdentifier
    }
    let jwkDto = Components.Schemas.KeyRequest(
      kty: publicKey.kty,
      kid: kid,
      crv: publicKey.crv,
      x: publicKey.x,
      y: publicKey.y,
    )
    let body = Components.Schemas.RegisterStateRequestDto(
      publicKey: jwkDto,
      overwrite: overwrite,
      ttl: ttl,
    )
    let input = Operations.RegisterState.Input(body: .json(body))
    let response = try await client.registerState(input)

    guard case let .created(payload) = response else {
      throw GatewayError.invalidResponse
    }

    guard let responseBody = try? payload.body.json else {
      throw GatewayError.undecodableResponseBody
    }

    let jwkKey = responseBody.serverJwsPublicKey.map {
      JwkKey(kty: $0.kty, crv: $0.crv, x: $0.x, y: $0.y, kid: $0.kid)
    }

    return RegisterStateResponse(
      clientId: responseBody.clientId,
      devAuthorizationCode: responseBody.devAuthorizationCode,
      serverJwsPublicKey: jwkKey,
      opaqueServerId: responseBody.opaqueServerId,
    )
  }

  public func registerPin(request: BFFRequest) async throws -> Data {
    let input = Operations.RegisterPin.Input(
      body: .json(.init(jwt: request.outerRequestJws, clientId: request.clientId))
    )
    let response = try await client.registerPin(input)

    guard case let .created(payload) = response else {
      throw GatewayError.invalidResponse
    }

    guard let jwt = try? payload.body.json.jwt else {
      throw GatewayError.undecodableResponseBody
    }

    return Data(jwt.utf8)
  }

  public func createSession(request: BFFRequest) async throws -> Data {
    let input = Operations.CreateHsmSession.Input(
      body: .json(.init(jwt: request.outerRequestJws, clientId: request.clientId))
    )
    let response = try await client.createHsmSession(input)

    guard case let .created(payload) = response else {
      throw GatewayError.invalidResponse
    }

    guard let jwt = try? payload.body.json.jwt else {
      throw GatewayError.undecodableResponseBody
    }

    return Data(jwt.utf8)
  }

  public func createKey(request: BFFRequest) async throws -> Data {
    let input = Operations.CreateKey.Input(
      body: .json(.init(jwt: request.outerRequestJws, clientId: request.clientId))
    )
    let response = try await client.createKey(input)

    guard case let .created(payload) = response else {
      throw GatewayError.invalidResponse
    }

    guard let jwt = try? payload.body.json.jwt else {
      throw GatewayError.undecodableResponseBody
    }

    return Data(jwt.utf8)
  }

  public func listKeys(request: BFFRequest) async throws -> Data {
    let input = Operations.ListKeys.Input(
      body: .json(.init(jwt: request.outerRequestJws, clientId: request.clientId))
    )
    let response = try await client.listKeys(input)

    guard case let .ok(payload) = response else {
      throw GatewayError.invalidResponse
    }

    guard let jwt = try? payload.body.json.jwt else {
      throw GatewayError.undecodableResponseBody
    }

    return Data(jwt.utf8)
  }

  public func sign(request: BFFRequest) async throws -> Data {
    let input = Operations.Sign.Input(
      body: .json(.init(jwt: request.outerRequestJws, clientId: request.clientId))
    )
    let response = try await client.sign(input)

    guard case let .ok(payload) = response else {
      throw GatewayError.invalidResponse
    }

    guard let jwt = try? payload.body.json.jwt else {
      throw GatewayError.undecodableResponseBody
    }

    return Data(jwt.utf8)
  }

  public func deleteKey(request: BFFRequest) async throws {
    let input = Operations.DeleteKey.Input(
      body: .json(.init(jwt: request.outerRequestJws, clientId: request.clientId))
    )
    let response = try await client.deleteKey(input)

    guard case .noContent = response else {
      throw GatewayError.invalidResponse
    }
  }
}
