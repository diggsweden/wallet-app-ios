// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import Foundation

struct OnboardingActions {
  let signIn: (String) async throws -> Void
  let savePidCredential: (SavedCredential) async throws -> Void
  let resetSession: () async throws -> Void
}
