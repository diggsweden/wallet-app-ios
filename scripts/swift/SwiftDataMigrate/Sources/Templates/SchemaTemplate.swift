// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

enum SchemaTemplate {
  static func copiedSchema(from previousBody: String, prevVersion: Int, nextVersion: Int) -> String {
    var body = previousBody

    body = body.replacingOccurrences(
      of: "SchemaV\(prevVersion)",
      with: "SchemaV\(nextVersion)"
    )

    let pattern = #"Schema\.Version\(\s*\d+"#
    body = body.replacingOccurrences(
      of: pattern,
      with: "Schema.Version(\(nextVersion)",
      options: .regularExpression
    )

    return body.trimmingCharacters(in: .whitespacesAndNewlines) + "\n"
  }
}
