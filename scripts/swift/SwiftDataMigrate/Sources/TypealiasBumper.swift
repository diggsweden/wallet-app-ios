// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

struct TypealiasBumper {
  let fromVersion: Int
  let toVersion: Int
  let file: URL

  @discardableResult
  func run() throws -> Bool {
    let original = try String(contentsOf: file, encoding: .utf8)
    let updated = original.replacingOccurrences(
      of: "SchemaV\(fromVersion).",
      with: "SchemaV\(toVersion)."
    )
    guard updated != original else { return false }
    try updated.write(to: file, atomically: true, encoding: .utf8)
    return true
  }
}
