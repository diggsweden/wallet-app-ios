// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import SwiftAccessMechanism
import WalletGatewayInterface

protocol WalletSetupService: Sendable {
  func createAccount() async throws
  func initHSMState() async throws
  func registerPin(pin: String) async throws -> StretchedPIN
}

actor BFFWalletSetupService: WalletSetupService {
  private let gatewayApi: any GatewayApi & HSMTransport
  private let onAccountCreated: @Sendable (String) async throws -> Void
  private let onServerParameters: @Sendable (ServerParameters) async throws -> Void
  private var bffClient: BFFHttpClient?

  init(
    gatewayApi: any GatewayApi & HSMTransport,
    onAccountCreated: @Sendable @escaping (String) async throws -> Void,
    onServerParameters: @Sendable @escaping (ServerParameters) async throws -> Void,
  ) {
    self.gatewayApi = gatewayApi
    self.onAccountCreated = onAccountCreated
    self.onServerParameters = onServerParameters
  }

  func createAccount() async throws {
    let key = try SigningKeyStore.getOrCreateKey(withTag: .deviceKey)
    let accountId = try await gatewayApi.createAccount(
      publicKey: try key.publicKey.toPublicKeyComponents()
    )
    try await onAccountCreated(accountId)
  }

  func initHSMState() async throws {
    let privateKey = try SecKeyStore.getOrCreateKey(withTag: .walletKey)
    let client = try await BFFHttpClient.create(
      transport: gatewayApi,
      privateKey: privateKey,
      ttl: "PT1H",
    )
    bffClient = client
    try await onServerParameters(client.serverParameters)
  }

  func registerPin(pin: String) async throws -> StretchedPIN {
    guard let client = bffClient else {
      throw WalletSetupError.missingBFFClient
    }

    let stretched = try PINStretch().stretch(input: Data(pin.utf8))
    _ = try await client.registration(password: stretched)
    return stretched
  }
}

enum WalletSetupError: Error {
  case missingBFFClient
  case missingKeyId
}
