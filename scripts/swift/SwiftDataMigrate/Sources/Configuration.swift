// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

enum Config {
  static let repoRootMarker = "Wallet"

  static let schemaDirectory = "Packages/User/Sources/User/Schema"
  static let migrationDirectory = "Packages/User/Sources/User/Migration"
  static let testsDirectory = "Packages/User/Tests/UserTests"
  static let currentModelsFile = "Packages/User/Sources/User/CurrentSchema.swift"

  static let migrationPlanFilename = "SwiftDataMigrationPlan.swift"

  static let fileHeader: String = """
    // SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
    //
    // SPDX-License-Identifier: EUPL-1.2
    """
}
