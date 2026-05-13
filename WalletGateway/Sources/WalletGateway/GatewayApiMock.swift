// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

public struct GatewayApiMock: GatewayApi {
  public init() {}

  public func createAccount(publicKey: PublicKeyComponents) throws -> String { "" }

  public func addAccountWalletKey(key: PublicKeyComponents) async throws {}

  public func getWalletUnitAttestation(nonce: String?) throws -> String { "" }
}
