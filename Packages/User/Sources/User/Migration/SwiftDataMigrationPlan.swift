// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import SwiftData

enum SwiftDataMigrationPlan: SchemaMigrationPlan {
  static var schemas: [any VersionedSchema.Type] {
    [SchemaV1.self, SchemaV2.self, SchemaV3.self]
  }

  static var stages: [MigrationStage] {
    [MigrateV1toV2.stage, MigrateV2toV3.stage]
  }
}
