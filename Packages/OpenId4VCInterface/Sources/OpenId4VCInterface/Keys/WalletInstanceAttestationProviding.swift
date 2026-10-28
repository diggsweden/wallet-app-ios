// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Jose

public protocol WalletInstanceAttestationProviding: Sendable {
  func walletInstanceAttestation(for publicKey: WalletJoseJWK) async throws -> String
}
