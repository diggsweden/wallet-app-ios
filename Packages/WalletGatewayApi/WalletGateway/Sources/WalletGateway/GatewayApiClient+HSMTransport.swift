// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import SwiftAccessMechanism

extension GatewayApiClient: HSMTransport {
  public func registerState(
    publicKey: JwkKey,
    overwrite: Bool,
    ttl: String?,
  ) async throws -> RegisterStateResponse {
    guard let kid = publicKey.kid else {
      throw GatewayError.missingKeyIdentifier
    }

    let ecKey = Components.Schemas.EcJwkRequest(
      kty: publicKey.kty,
      kid: kid,
      crv: publicKey.crv,
      x: publicKey.x,
      y: publicKey.y,
    )
    let body = Components.Schemas.RegisterStateRequest(
      deviceKey: ecKey,
      ttl: ttl,
    )
    let input = Operations.SaveState.Input(body: .json(body))
    let response = try await client.saveState(input)

    guard case let .created(payload) = response else {
      throw GatewayError.invalidResponse
    }

    let responseBody = try payload.body.json

    let jwkKey = responseBody.serverJwsPublicKey.map { jwk in
      let key = jwk.value1
      return JwkKey(
        kty: key.kty,
        crv: key.crv,
        x: key.x,
        y: key.y,
        kid: key.kid,
      )
    }

    return RegisterStateResponse(
      devAuthorizationCode: responseBody.devAuthorizationCode,
      serverJwsPublicKey: jwkKey,
      opaqueServerId: responseBody.opaqueServerId,
    )
  }

  @discardableResult
  public func perform(_ request: HSMRequest, operation: HSMOperation) async throws -> Data {
    let body = Components.Schemas.HsmRequest(outerRequestJws: request.outerRequestJws)
    let query = Operations.CreateRequest.Input.Query(_type: hsmRequestType(for: operation))
    let input = Operations.CreateRequest.Input(query: query, body: .json(body))

    switch try await client.createRequest(input) {
      case let .ok(p):
        guard let dto = try? p.body.json else {
          throw GatewayError.undecodableResponseBody
        }
        return try extractResult(from: dto)

      case let .accepted(p):
        guard let dto = try? p.body.json else {
          throw GatewayError.undecodableResponseBody
        }
        return try await pollUntilComplete(id: dto.id)

      default:
        throw GatewayError.invalidResponse
    }
  }

  // MARK: - Private

  private func hsmRequestType(for operation: HSMOperation) -> Components.Schemas.HsmRequestType {
    switch operation {
      case .createSession: return .createSession
      case .createKey: return .createKey
      case .listKeys: return .listKeys
      case .deleteKey: return .deleteKey
      case .registerPin: return .registerPin
      case .changePin: return .changePin
      case .sign: return .sign
    }
  }

  private func extractResult(from dto: Components.Schemas.HsmResponse) throws -> Data {
    if dto.status == .error {
      throw GatewayError.asyncOperationFailed(message: "HSM operation failed")
    }

    guard let result = dto.result else {
      throw GatewayError.undecodableResponseBody
    }

    return Data(result.utf8)
  }

  private func pollUntilComplete(id: String) async throws -> Data {
    let maxAttempts = 30
    let pollInterval: Duration = .seconds(1)

    for _ in 0 ..< maxAttempts {
      try await Task.sleep(for: pollInterval)

      let input = Operations.GetResult.Input(path: .init(id: id))
      let response = try await client.getResult(input)

      switch response {
        case let .ok(payload):
          guard let dto = try? payload.body.json else {
            throw GatewayError.undecodableResponseBody
          }

          return try extractResult(from: dto)

        case .accepted:
          continue

        default:
          throw GatewayError.invalidResponse
      }
    }

    throw GatewayError.asyncOperationTimeout
  }
}
