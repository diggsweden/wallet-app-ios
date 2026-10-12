// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Jose
import OpenId4VCInterface

/// Returns a fixed attestation and records the keys and nonce of every request.
public actor FakeKeyAttestationProvider: KeyAttestationProviding {
  public struct Request: Sendable {
    public let publicKeys: [WalletJoseJWK]
    public let nonce: String?
  }

  nonisolated public let attestation: String
  public private(set) var requests: [Request] = []

  public init(attestation: String = "attestation-jwt") {
    self.attestation = attestation
  }

  // swiftlint:disable async_without_await
  public func keyAttestation(
    for publicKeys: [WalletJoseJWK],
    nonce: String?,
  ) async throws
    -> String
  {
    requests.append(Request(publicKeys: publicKeys, nonce: nonce))
    return attestation
  }
  // swiftlint:enable async_without_await
}
