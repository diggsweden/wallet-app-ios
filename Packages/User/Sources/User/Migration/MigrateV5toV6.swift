import Foundation
import SwiftData

enum MigrateV5toV6 {
  static let stage = MigrationStage.lightweight(
    fromVersion: SchemaV5.self,
    toVersion: SchemaV6.self,
  )
}
