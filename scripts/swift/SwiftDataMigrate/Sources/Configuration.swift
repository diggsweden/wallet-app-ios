// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

enum Config {
  static let repoRootMarker = "Wallet"

  static let schemaDirectory = "Wallet/Core/Persistence/Schema"
  static let migrationDirectory = "Wallet/Core/Persistence/Migration"
  static let testsDirectory = "WalletTests/Persistence"

  static let migrationPlanFilename = "SwiftDataMigrationPlan.swift"

  static let fileHeader: String = """
    // SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
    //
    // SPDX-License-Identifier: EUPL-1.2
    """
}
