// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

public protocol ProofKeyStore: Sendable {
  func authenticate() async throws
  func createKey() async throws -> ProofKey
  func deleteKey(id: ProofKey.ID) async throws
}
