// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Security
import SwiftAccessMechanism
import SwiftUI

@MainActor
@Observable
final class RegisterPinViewModel {
  private let transport: any BFFTransport

  init(transport: any BFFTransport) {
    self.transport = transport
  }

  func register(pin: String) async throws {
    let serverId = Data("dev.cloud-wallet.digg.se".utf8)
    let privateKey = try BFFIdentity.generateKey(tag: "bff-hsm-key")
    var client = try await BFFHttpClient.create(
      transport: transport,
      privateKey: privateKey,
      serverParameters: ServerParameters(serverIdentifier: serverId),
      ttl: "PT1H",
    )

    let stretched = try PINStretch().stretch(input: Data(pin.utf8))

    let registrationResponse = try await client.registration(password: stretched)
    print("DEBUG: Registration Response: \(registrationResponse)")

    let authResult = try await client.authenticate(password: stretched)
    print("DEBUG: Auth session key: \(authResult.sessionKey.count) bytes")

    let createdKey = try await client.createHsmKey()
    print("DEBUG: HSM-key: \(createdKey.public_key)")
  }
}
