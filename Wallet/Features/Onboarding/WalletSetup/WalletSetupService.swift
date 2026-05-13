// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import SwiftAccessMechanism
import WalletGateway

protocol WalletSetupService: Sendable {
  func createAccount() async throws
  func initHSMState() async throws
  func registerPin(pin: String) async throws -> StretchedPIN
  func authenticate(pin: StretchedPIN) async throws
  func generateHSMKey() async throws -> PublicKeyComponents
  func saveKey(key: PublicKeyComponents) async throws
}

actor BFFWalletSetupService: WalletSetupService {
  private let transport: any BFFTransport
  private let gatewayApi: any GatewayApi
  private let onAccountCreated: @Sendable (String) async throws -> Void
  private var bffClient: BFFHttpClient?

  init(
    transport: any BFFTransport,
    gatewayApi: any GatewayApi,
    onAccountCreated: @Sendable @escaping (String) async throws -> Void,
  ) {
    self.transport = transport
    self.gatewayApi = gatewayApi
    self.onAccountCreated = onAccountCreated
  }

  func createAccount() async throws {
    let key = try SigningKeyStore.getOrCreateKey(withTag: .deviceKey)
    let accountId = try await gatewayApi.createAccount(
      publicKey: try key.publicKey.toPublicKeyComponents()
    )
    try await onAccountCreated(accountId)
  }

  func initHSMState() async throws {
    let serverId = Data("dev.cloud-wallet.digg.se".utf8)
    let privateKey = try BFFIdentity.generateKey(tag: "bff-hsm-key")
    bffClient = try await BFFHttpClient.create(
      transport: transport,
      privateKey: privateKey,
      serverParameters: ServerParameters(serverIdentifier: serverId),
      ttl: "PT1H",
    )
  }

  func registerPin(pin: String) async throws -> StretchedPIN {
    guard let client = bffClient else {
      throw WalletSetupError.missingBFFClient
    }

    let stretched = try PINStretch().stretch(input: Data(pin.utf8))
    let response = try await client.registration(password: stretched)
    print("DEBUG: Registration response: \(response)")
    return stretched
  }

  func authenticate(pin: StretchedPIN) async throws {
    guard let client = bffClient else {
      throw WalletSetupError.missingBFFClient
    }

    let result = try await client.authenticate(password: pin)
    print("DEBUG: Auth session key: \(result.sessionKey.count) bytes")
  }

  func generateHSMKey() async throws -> PublicKeyComponents {
    guard let client = bffClient else {
      throw WalletSetupError.missingBFFClient
    }

    let key = try await client.createHsmKey()
    let jwk = key.public_key

    guard let kid = jwk.kid else {
      throw WalletSetupError.missingKeyId
    }

    return PublicKeyComponents(kty: jwk.kty, kid: kid, crv: jwk.crv, x: jwk.x, y: jwk.y)
  }

  func saveKey(key: PublicKeyComponents) async throws {
    try await gatewayApi.addAccountWalletKey(key: key)
  }
}

enum WalletSetupError: Error {
  case missingBFFClient
  case missingKeyId
}
