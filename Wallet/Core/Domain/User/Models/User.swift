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
  var credential: Credential?

  init() {}
}
