// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import Foundation

struct IssuanceActions {
  let onSaveCredential: (SavedCredential) async throws -> Void
  let onComplete: () async throws -> Void
  let onDismiss: () async -> Void
}
