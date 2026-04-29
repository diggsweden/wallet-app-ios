// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

enum MigrationTemplate {
  static func lightweight(prev: Int, next: Int) -> String {
    """
    import Foundation
    import SwiftData

    enum MigrateV\(prev)toV\(next) {
      static let stage = MigrationStage.lightweight(
        fromVersion: SchemaV\(prev).self,
        toVersion: SchemaV\(next).self
      )
    }

    """
  }

  static func custom(prev: Int, next: Int) -> String {
    """
    import Foundation
    import SwiftData

    enum MigrateV\(prev)toV\(next) {
      static let stage = MigrationStage.custom(
        fromVersion: SchemaV\(prev).self,
        toVersion: SchemaV\(next).self,
        willMigrate: { context in
          // TODO: Capture data from V\(prev) needed to populate V\(next).
        },
        didMigrate: { context in
          // TODO: Populate V\(next) using the captured data.
          try context.save()
        }
      )
    }

    """
  }
}
