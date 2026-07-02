// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import Foundation
import SwiftAccessMechanism

struct OnboardingActions {
  let signIn: (String) async throws -> Void
  let savePidCredential: (SavedCredential) async throws -> Void
  let resetSession: () async throws -> Void
  let saveHsmServerParameters: (ServerParameters) async throws -> Void
}
