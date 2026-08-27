// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import SwiftData

enum MigrateV3toV4 {
  static let stage = MigrationStage.custom(
    fromVersion: SchemaV3.self,
    toVersion: SchemaV4.self,
    willMigrate: { context in
      let users = try context.fetch(FetchDescriptor<SchemaV3.User>())
      for user in users {
        if let pid = user.pid {
          user.credentials.insert(pid, at: 0)
          user.pid = nil
        }
      }
      try context.save()
    },
    didMigrate: nil,
  )
}
