// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

struct UserSnapshot: Sendable {
  let deviceId: String
  let accountId: String?
  let credential: Credential?
}
