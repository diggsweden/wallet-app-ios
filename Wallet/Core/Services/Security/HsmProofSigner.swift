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

actor HsmProofSigner: ProofSigner {
  private let transport: any HSMTransport
  private let parameters: HsmServerParameters?
  private let pin: String
  private var session: HsmSession?

  init(transport: any HSMTransport, parameters: HsmServerParameters?, pin: String) {
    self.transport = transport
    self.parameters = parameters
    self.pin = pin
  }

  func sign(_ signingInput: Data) async throws -> String {
    let session = try await authenticatedSession()
    return try await session.client.sign(hsmKeyId: session.keyId, data: signingInput).signature
  }

  func publicKey() async throws -> WalletJoseJWK {
    try await authenticatedSession().publicKey
  }

  private func authenticatedSession() async throws -> HsmSession {
    if let session {
      return session
    }

    guard let parameters else {
      throw HsmSignerError.missingConfig
    }

    let client = try BFFHttpClient.resume(
      transport: transport,
      privateKey: SecKeyStore.getOrCreateKey(withTag: .walletKey),
      serverParameters: parameters.toServerParameters(),
    )
    _ = try await client.authenticate(password: PINStretch().stretch(input: Data(pin.utf8)))

    guard
      let key = try await client.listKeys().keyInfo.first,
      let keyId = key.kid
    else {
      throw HsmSignerError.noKey
    }

    let session = HsmSession(
      client: client,
      keyId: keyId,
      publicKey: try WalletJoseJWK(secKey: key.publicKey.toSecKey()),
    )
    self.session = session
    return session
  }
}

private struct HsmSession {
  let client: BFFHttpClient
  let keyId: String
  let publicKey: WalletJoseJWK
}
