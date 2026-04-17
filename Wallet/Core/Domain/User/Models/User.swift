// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import SwiftData

@Model
final class User {
  @Attribute(.unique) var id = 0
  var deviceId: String = UUID().uuidString
  var accountId: String?
  var credentials: [SavedCredential]
  var pid: SavedCredential?

  init(
    id: Int = 0,
    deviceId: String = UUID().uuidString,
    accountId: String? = nil,
    credentials: [SavedCredential] = [],
    pid: SavedCredential? = nil
  ) {
    self.id = id
    self.deviceId = deviceId
    self.accountId = accountId
    self.credentials = credentials
    self.pid = pid
  }
}
