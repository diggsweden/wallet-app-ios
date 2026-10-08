// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import WalletGatewayInterface

public struct GatewayApiMock: GatewayApi {
  public init() {}

  public func getDatabaseGeneration() throws -> Int {
    0
  }

  public func createAccount(publicKey: PublicKeyComponents) throws -> String { "" }

  public func getKeyAttestation(
    keys: [PublicKeyComponents],
    nonce: String?,
  ) throws -> String { "" }
}
