// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

enum TestTemplate {
  static func scaffold(prev: Int, next: Int) -> String {
    """
    import Foundation
    import SwiftData
    import Testing

    @Suite("V\(prev) to V\(next) migration")
    struct MigrateV\(prev)toV\(next)Tests {
      // TODO: Add @Test functions here.
    }

    private extension MigrateV\(prev)toV\(next)Tests {
      // TODO: Place fixture factories for SchemaV\(prev) and SchemaV\(next) here.
    }

    """
  }
}
