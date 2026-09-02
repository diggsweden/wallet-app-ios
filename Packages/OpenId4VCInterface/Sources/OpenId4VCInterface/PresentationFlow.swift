// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import Foundation

public protocol PresentationFlow: Sendable {
  func resolve(url: URL, credentials: [SavedCredential]) async throws -> ResolvedPresentation
  func submit(
    _ resolved: ResolvedPresentation,
    selectedIds: [String],
    signer: any ProofSigner,
  ) async throws -> PresentationOutcome
}
