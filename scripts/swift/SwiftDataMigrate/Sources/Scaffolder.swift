// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

final class Scaffolder {
  let context: ProjectContext

  private let nextVersion: Int
  private let stageKind: StageKind
  private(set) var typealiasFilesUpdated: [URL] = []

  init(context: ProjectContext, nextVersion: Int, stageKind: StageKind) {
    self.context = context
    self.nextVersion = nextVersion
    self.stageKind = stageKind
  }

  private var prevVersion: Int { context.latestVersion }

  func run() throws {
    guard prevVersion > .zero else { throw SwiftDataMigrationError.prevVersionWasZero }
    
    try createNewSchemaFile()
    try createMigrationStageFile()
    try createTestFile()
    try updateMigrationPlan()
    try bumpTypealiases()
  }

  func runXcodegen(at repoRoot: URL) throws {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = ["xcodegen"]
    process.currentDirectoryURL = repoRoot

    try process.run()
    process.waitUntilExit()

    guard process.terminationStatus == .zero else {
      throw SwiftDataMigrationError.xcodegenFailed(exitCode: process.terminationStatus)
    }
  }
}

private extension Scaffolder {
  func createNewSchemaFile() throws {
    let destination = context.schemaDir.appendingPathComponent("SchemaV\(nextVersion).swift")
    try ensureDoesNotExist(destination)

    let body: String
    let previousURL = context.schemaDir.appendingPathComponent("SchemaV\(prevVersion).swift")
    let previousContent = try String(contentsOf: previousURL, encoding: .utf8)
    let stripped = try stripFileHeader(from: previousContent, sourcePath: previousURL.path)
    body = SchemaTemplate.copiedSchema(
      from: stripped,
      prevVersion: prevVersion,
      nextVersion: nextVersion
    )

    try writeFile(at: destination, body: body)
  }

  private func stripFileHeader(from content: String, sourcePath: String) throws -> String {
    let header = "\(Config.fileHeader)\n\n"
    guard content.hasPrefix(header) else {
      throw SwiftDataMigrationError.invalidHeader(path: sourcePath)
    }
    return String(content.dropFirst(header.count))
  }
  
  func createMigrationStageFile() throws {
    let destination = context.migrationDir.appendingPathComponent(
      "MigrateV\(prevVersion)toV\(nextVersion).swift"
    )
    try ensureDoesNotExist(destination)

    let body: String
    switch stageKind {
    case .lightweight:
      body = MigrationTemplate.lightweight(prev: prevVersion, next: nextVersion)
    case .custom:
      body = MigrationTemplate.custom(prev: prevVersion, next: nextVersion)
    }

    try writeFile(at: destination, body: body)
  }
  
  func createTestFile() throws {
    let destination = context.testsDir.appendingPathComponent(
      "MigrateV\(prevVersion)toV\(nextVersion)Tests.swift"
    )
    try ensureDoesNotExist(destination)

    let body = TestTemplate.scaffold(prev: prevVersion, next: nextVersion)
    try writeFile(at: destination, body: body)
  }
  
  func updateMigrationPlan() throws {
    let allVersions = (context.existingVersions + [nextVersion]).sorted()
    let body = MigrationPlanTemplate.render(versions: allVersions)
    let fullContent = "\(Config.fileHeader)\n\n\(body)"
    try fullContent.write(to: context.planFile, atomically: true, encoding: .utf8)
  }
  
  func bumpTypealiases() throws {
    guard prevVersion > .zero else { return }

    let bumper = TypealiasBumper(
      fromVersion: prevVersion,
      toVersion: nextVersion,
      repoRoot: context.repoRoot,
      excludeDirectory: context.schemaDir
    )
    typealiasFilesUpdated = try bumper.run()
  }
  
  func ensureDoesNotExist(_ url: URL) throws {
    if FileManager.default.fileExists(atPath: url.path) {
      throw SwiftDataMigrationError.fileAlreadyExists(path: url.path)
    }
  }

  func writeFile(at url: URL, body: String) throws {
    let fullContent = "\(Config.fileHeader)\n\n\(body)"
    try fullContent.write(to: url, atomically: true, encoding: .utf8)
  }
}
