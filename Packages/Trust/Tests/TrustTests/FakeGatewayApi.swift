// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import WalletGatewayInterface

actor FakeGatewayApi: GatewayApi {
  struct Failure: Error {}

  private let providerUrls: [URL]?
  private let failingCalls: Int
  private(set) var providerFetchCount = 0

  init(providerUrls: [URL]?, failingCalls: Int = 0) {
    self.providerUrls = providerUrls
    self.failingCalls = failingCalls
  }

  func createAccount(publicKey: PublicKeyComponents) throws -> String { "" }

  func getKeyAttestation(keys: [PublicKeyComponents], nonce: String?) throws -> String { "" }

  func getDatabaseGeneration() throws -> Int { 0 }

  func fetchTrustedListProviders() throws -> [URL] {
    providerFetchCount += 1

    guard providerFetchCount > failingCalls, let providerUrls else {
      throw Failure()
    }

    return providerUrls
  }
}
