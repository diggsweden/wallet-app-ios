// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

public protocol KeyAttestationProviding: Sendable {
  func keyAttestation(nonce: String?) async throws -> String
}
