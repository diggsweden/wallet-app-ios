// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces

public struct UserSnapshot: Equatable, Sendable {
  public let accountId: String?
  public let credentials: [SavedCredential]
  public let pid: SavedCredential?
}
