// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

public protocol GatewayApi: Sendable {
  func createAccount(publicKey: PublicKeyComponents) async throws -> String
  func getKeyAttestation(keys: [PublicKeyComponents], nonce: String?) async throws -> String
}
