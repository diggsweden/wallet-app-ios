// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftData

enum MigrateV4toV5 {
  static let stage = MigrationStage.custom(
    fromVersion: SchemaV4.self,
    toVersion: SchemaV5.self,
    willMigrate: nil,
    didMigrate: { context in
      for user in try context.fetch(FetchDescriptor<SchemaV5.User>()) {
        user.isReset = true
      }
      try context.save()
    },
  )
}
