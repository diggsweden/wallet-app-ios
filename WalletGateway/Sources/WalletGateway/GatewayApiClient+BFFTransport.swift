// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import SwiftAccessMechanism

extension GatewayApiClient: BFFTransport {
  public func changePin(request: BFFRequest) async throws -> Data {
    switch try await client.changePinAsync(.init(body: .json(hsmBody(request)))) {
      case let .ok(p): try await resolveAsync(ok: try? p.body.json)
      case let .accepted(p): try await resolveAsync(pending: try? p.body.json)
      default: throw GatewayError.invalidResponse
    }
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
    switch try await client.registerPinAsync(.init(body: .json(hsmBody(request)))) {
      case let .ok(p): try await resolveAsync(ok: try? p.body.json)
      case let .accepted(p): try await resolveAsync(pending: try? p.body.json)
      default: throw GatewayError.invalidResponse
    }
  }

  public func createSession(request: BFFRequest) async throws -> Data {
    switch try await client.createHsmSessionAsync(.init(body: .json(hsmBody(request)))) {
      case let .ok(p): try await resolveAsync(ok: try? p.body.json)
      case let .accepted(p): try await resolveAsync(pending: try? p.body.json)
      default: throw GatewayError.invalidResponse
    }
  }

  public func createKey(request: BFFRequest) async throws -> Data {
    switch try await client.createKeyAsync(.init(body: .json(hsmBody(request)))) {
      case let .ok(p): try await resolveAsync(ok: try? p.body.json)
      case let .accepted(p): try await resolveAsync(pending: try? p.body.json)
      default: throw GatewayError.invalidResponse
    }
  }

  public func listKeys(request: BFFRequest) async throws -> Data {
    switch try await client.listKeysAsync(.init(body: .json(hsmBody(request)))) {
      case let .ok(p): try await resolveAsync(ok: try? p.body.json)
      case let .accepted(p): try await resolveAsync(pending: try? p.body.json)
      default: throw GatewayError.invalidResponse
    }
  }

  public func sign(request: BFFRequest) async throws -> Data {
    switch try await client.signAsync(.init(body: .json(hsmBody(request)))) {
      case let .ok(p): try await resolveAsync(ok: try? p.body.json)
      case let .accepted(p): try await resolveAsync(pending: try? p.body.json)
      default: throw GatewayError.invalidResponse
    }
  }

  public func deleteKey(request: BFFRequest) async throws {
    switch try await client.deleteKeyAsync(.init(body: .json(hsmBody(request)))) {
      case let .ok(p): _ = try await resolveAsync(ok: try? p.body.json)
      case let .accepted(p): _ = try await resolveAsync(pending: try? p.body.json)
      default: throw GatewayError.invalidResponse
    }
  }

  // MARK: - Private

  private func hsmBody(_ request: BFFRequest) -> Components.Schemas.HsmRequestDto {
    .init(jwt: request.outerRequestJws, clientId: request.clientId, stateJws: request.stateJws)
  }

  private func resolveAsync(ok dto: Components.Schemas.AsyncHsmResponseDto?) async throws -> Data {
    guard let dto else {
      throw GatewayError.undecodableResponseBody
    }

    return try await extractResult(from: dto)
  }

  private func resolveAsync(
    pending dto: Components.Schemas.AsyncHsmResponseDto?
  ) async throws -> Data {
    guard let dto else {
      throw GatewayError.undecodableResponseBody
    }

    return try await pollUntilComplete(correlationId: dto.correlationId)
  }

  private func extractResult(from dto: Components.Schemas.AsyncHsmResponseDto) async throws -> Data
  {
    if let error = dto.error {
      throw GatewayError.asyncOperationFailed(message: error.message)
    }

    if let stateJws = dto.stateJws {
      do {
        let response = try await client.addAccountSecurityEnvelope(
          .init(body: .json(.init(_type: .sign, content: stateJws)))
        )
        
        guard case .created = response else {
          throw GatewayError.asyncOperationFailed(message: "Failed to add account security envelope")
        }
      } catch {
        print(error)
      }
    }

    guard let result = dto.result else {
      throw GatewayError.undecodableResponseBody
    }

    return Data(result.utf8)
  }

  private func pollUntilComplete(correlationId: String) async throws -> Data {
    let maxAttempts = 30
    let pollInterval: Duration = .seconds(1)

    for _ in 0 ..< maxAttempts {
      try await Task.sleep(for: pollInterval)

      let input = Operations.GetHsmRequest.Input(path: .init(correlationId: correlationId))
      let response = try await client.getHsmRequest(input)

      switch response {
        case let .ok(payload):
          guard let dto = try? payload.body.json else {
            throw GatewayError.undecodableResponseBody
          }

          return try await extractResult(from: dto)
        case .accepted:
          continue
        default:
          throw GatewayError.invalidResponse
      }
    }

    throw GatewayError.asyncOperationTimeout
  }
}
