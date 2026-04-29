// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

struct TypealiasBumper {
  let fromVersion: Int
  let toVersion: Int
  let repoRoot: URL
  let excludeDirectory: URL

  private var current: String { "SchemaV\(fromVersion)\\." }
  private var replacement: String { "SchemaV\(toVersion)." }

  func run() throws -> [URL] {
    var updatedFiles: [URL] = []
    for url in swiftFiles() {
      if try rewriteTypealiases(in: url) {
        updatedFiles.append(url)
      }
    }
    return updatedFiles
  }

  private func swiftFiles() -> [URL] {
    guard let enumerator = FileManager.default.enumerator(
      at: repoRoot,
      includingPropertiesForKeys: [.isRegularFileKey],
      options: [.skipsHiddenFiles, .skipsPackageDescendants]
    ) else { return [] }

    var results: [URL] = []
    for case let url as URL in enumerator {
      guard url.pathExtension == "swift" else { continue }
      guard !url.path.hasPrefix(excludeDirectory.path) else { continue }
      results.append(url)
    }
    return results
  }

  private func rewriteTypealiases(in url: URL) throws -> Bool {
    let content = try String(contentsOf: url, encoding: .utf8)
    let lines = content.components(separatedBy: "\n")

    var updatedLines = lines
    var changed = false

    for (index, line) in lines.enumerated() {
      guard isTypealiasLine(line) else { continue }

      let updated = line.replacingOccurrences(
        of: current,
        with: replacement,
        options: .regularExpression
      )
      if updated != line {
        updatedLines[index] = updated
        changed = true
      }
    }

    if changed {
      try updatedLines.joined(separator: "\n").write(to: url, atomically: true, encoding: .utf8)
    }
    return changed
  }

  private func isTypealiasLine(_ line: String) -> Bool {
    line.trimmingCharacters(in: .whitespaces).hasPrefix("typealias ")
  }
}
