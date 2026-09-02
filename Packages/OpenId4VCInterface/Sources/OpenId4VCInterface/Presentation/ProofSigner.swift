// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Jose

public protocol ProofSigner: Sendable {
  func sign(_ signingInput: Data) async throws -> String
  func publicKey() async throws -> WalletJoseJWK
}
