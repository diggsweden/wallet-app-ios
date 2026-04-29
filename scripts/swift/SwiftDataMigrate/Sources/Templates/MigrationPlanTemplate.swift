// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

enum MigrationPlanTemplate {
  static func render(versions: [Int]) -> String {
    precondition(!versions.isEmpty, "Cannot render a plan with zero schemas.")
    precondition(versions == versions.sorted(), "Versions must be sorted ascending.")

    let schemaEntries = versions
      .map { "SchemaV\($0).self" }
      .joined(separator: ", ")

    let stageEntries = zip(versions, versions.dropFirst())
      .map { "MigrateV\($0.0)toV\($0.1).stage" }
      .joined(separator: ", ")

    return """
    import Foundation
    import SwiftData

    enum SwiftDataMigrationPlan: SchemaMigrationPlan {
      static var schemas: [any VersionedSchema.Type] {
        [\(schemaEntries)]
      }

      static var stages: [MigrationStage] {
        [\(stageEntries)]
      }
    }

    """
  }
}
