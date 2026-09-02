// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
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
  private var session: (client: BFFHttpClient, keyId: String)?

  init(transport: any HSMTransport, parameters: HsmServerParameters?, pin: String) {
    self.transport = transport
    self.parameters = parameters
    self.pin = pin
  }

  func sign(_ signingInput: Data) async throws -> String {
    let (client, keyId) = try await authenticatedSession()
    return try await client.sign(hsmKeyId: keyId, data: signingInput).signature
  }

  private func authenticatedSession() async throws -> (client: BFFHttpClient, keyId: String) {
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

    guard let keyId = try await client.listKeys().keyInfo.first?.kid else {
      throw HsmSignerError.noKey
    }

    let session = (client: client, keyId: keyId)
    self.session = session
    return session
  }
}
