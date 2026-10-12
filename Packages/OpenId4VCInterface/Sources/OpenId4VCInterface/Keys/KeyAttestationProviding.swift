// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Jose

public protocol KeyAttestationProviding: Sendable {
  func keyAttestation(for publicKeys: [WalletJoseJWK], nonce: String?) async throws -> String
}
