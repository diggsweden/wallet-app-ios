// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Jose
import OpenId4VCInterface

/// Returns a fixed attestation and records the key of every request.
public actor FakeWalletInstanceAttestationProvider: WalletInstanceAttestationProviding {
  nonisolated public let attestation: String
  public private(set) var requestedKeys: [WalletJoseJWK] = []

  public init(attestation: String = "wia-jwt") {
    self.attestation = attestation
  }

  // swiftlint:disable:next async_without_await
  public func walletInstanceAttestation(for publicKey: WalletJoseJWK) async throws -> String {
    requestedKeys.append(publicKey)
    return attestation
  }
}
