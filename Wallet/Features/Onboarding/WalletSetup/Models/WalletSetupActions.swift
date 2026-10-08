// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftAccessMechanism

struct WalletSetupActions {
  let onAccountCreated: @Sendable (String) async throws -> Void
  let onServerParameters: @Sendable (ServerParameters) async throws -> Void
  let onBackendGeneration: @Sendable (Int) async throws -> Void
  let onComplete: () -> Void
}
