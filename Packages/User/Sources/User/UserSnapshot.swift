// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import Foundation

public struct UserSnapshot: Equatable, Sendable {
  public let accountId: String?
  public let credentials: [SavedCredential]
  public let hsmServerParameters: HsmServerParameters?
  public let isOnboardingCompleted: Bool
  public let isReset: Bool
  public let backendResetAt: Date?

  public var hasPid: Bool {
    credentials.first != nil
  }

  public var hasCompletedOnboarding: Bool {
    accountId != nil && hasPid && isOnboardingCompleted
  }
}
