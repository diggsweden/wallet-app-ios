// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import SwiftData

enum MigrateV2toV3 {
  static let stage = MigrationStage.lightweight(
    fromVersion: SchemaV2.self,
    toVersion: SchemaV3.self,
  )
}
