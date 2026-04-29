// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

struct ProjectContext {
  let repoRoot: URL
  let schemaDir: URL
  let migrationDir: URL
  let testsDir: URL
  let planFile: URL
  let existingVersions: [Int]

  var latestVersion: Int { existingVersions.last ?? .zero }

  static func discover() throws -> ProjectContext {
    try discover(repoRoot: findRepoRoot())
  }

  static func discover(repoRoot: URL) throws -> ProjectContext {
    let schemaDir = repoRoot.appendingPathComponent(Config.schemaDirectory)
    let migrationDir = repoRoot.appendingPathComponent(Config.migrationDirectory)
    let testsDir = repoRoot.appendingPathComponent(Config.testsDirectory)
    let planFile = migrationDir.appendingPathComponent(Config.migrationPlanFilename)

    for dir in [schemaDir, migrationDir, testsDir] {
      var isDir: ObjCBool = false
      guard FileManager.default.fileExists(atPath: dir.path, isDirectory: &isDir), isDir.boolValue else {
        throw SwiftDataMigrationError.directoryMissing(path: dir.path)
      }
    }

    return ProjectContext(
      repoRoot: repoRoot,
      schemaDir: schemaDir,
      migrationDir: migrationDir,
      testsDir: testsDir,
      planFile: planFile,
      existingVersions: try discoverAllSchemaVersions(in: schemaDir)
    )
  }

  private static func findRepoRoot() throws -> URL {
    let fileManager = FileManager.default
    var current = URL(fileURLWithPath: fileManager.currentDirectoryPath)

    while current.path != "/" {
      let marker = current.appendingPathComponent(Config.repoRootMarker, isDirectory: true)
      var isDir: ObjCBool = false
      if fileManager.fileExists(atPath: marker.path, isDirectory: &isDir), isDir.boolValue {
        return current
      }
      current.deleteLastPathComponent()
    }

    throw SwiftDataMigrationError.repoRootNotFound(marker: Config.repoRootMarker)
  }

  private static func discoverAllSchemaVersions(in dir: URL) throws -> [Int] {
    let files = try FileManager.default.contentsOfDirectory(atPath: dir.path)
    let regex = try NSRegularExpression(pattern: #"^SchemaV(\d+)\.swift$"#)

    var versions: [Int] = []
    for name in files {
      let range = NSRange(name.startIndex..., in: name)
      guard let match = regex.firstMatch(in: name, range: range),
            let versionRange = Range(match.range(at: 1), in: name),
            let version = Int(name[versionRange])
      else { continue }
      versions.append(version)
    }
    return versions.sorted()
  }
}
