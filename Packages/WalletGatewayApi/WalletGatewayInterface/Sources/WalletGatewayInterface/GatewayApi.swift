// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

public protocol GatewayApi: Sendable {
  func createAccount(publicKey: PublicKeyComponents) async throws -> String

  func addAccountWalletKey(key: PublicKeyComponents) async throws

  func getWalletUnitAttestation(nonce: String?) async throws -> String
}
