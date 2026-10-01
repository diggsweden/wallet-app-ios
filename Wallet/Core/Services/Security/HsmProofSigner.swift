// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Jose
import OpenId4VCInterface
import SwiftAccessMechanism
import User

enum HsmSignerError: Error {
  case missingConfig
  case noKey
}

actor HsmProofSigner: ProofSigner, ProofKeyStore {
  private var client: BFFHttpClient?
  private let transport: any HSMTransport
  private let parameters: HsmServerParameters?
  private let pin: String

  init(transport: any HSMTransport, parameters: HsmServerParameters?, pin: String) {
    self.transport = transport
    self.parameters = parameters
    self.pin = pin
  }

  func sign(_ signingInput: Data, keyId: ProofKey.ID) async throws -> String {
    try await getClient().sign(hsmKeyId: keyId.rawValue, data: signingInput).signature
  }

  func authenticate() async throws {
    client = try await makeAuthenticatedClient()
  }

  func createKey() async throws -> ProofKey {
    let key = try await getClient().createHsmKey().public_key

    guard let keyId = key.kid else {
      throw IssuanceError.noKeyId
    }

    let walletJoseJwk = try WalletJoseJWK(key)

    return ProofKey(id: .init(keyId), publicKey: walletJoseJwk)
  }

  func deleteKey(id: ProofKey.ID) async throws {
    try await getClient().deleteKey(hsmKeyId: id.rawValue)
  }

  private func getClient() async throws -> BFFHttpClient {
    if let client = client.take() {
      return client
    }

    return try await makeAuthenticatedClient()
  }

  private func makeAuthenticatedClient() async throws -> BFFHttpClient {
    guard let parameters else {
      throw HsmSignerError.missingConfig
    }

    let client = try BFFHttpClient.resume(
      transport: transport,
      privateKey: SecKeyStore.getOrCreateKey(withTag: .walletKey),
      serverParameters: parameters.toServerParameters(),
    )
    _ = try await client.authenticate(password: PINStretch().stretch(input: Data(pin.utf8)))

    return client
  }
}

private struct HsmSession {
  let client: BFFHttpClient
  let keyId: String
  let publicKey: WalletJoseJWK
}
