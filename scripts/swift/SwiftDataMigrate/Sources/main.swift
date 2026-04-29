import ArgumentParser
import Foundation

struct SwiftDataMigrate: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "swiftdata-migrate",
    abstract: "Scaffolding for SwiftData schema versions and migrations.",
    subcommands: [NewCommand.self],
    defaultSubcommand: NewCommand.self
  )
}

struct NewCommand: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "new",
    abstract: "Scaffold the next schema version and its migration stage."
  )

  @Flag(name: .long, help: "Generate a lightweight migration stage (default).")
  var lightweight: Bool = false

  @Flag(name: .long, help: "Generate a custom migration stage with willMigrate/didMigrate stubs.")
  var custom: Bool = false

  func validate() throws {
    if lightweight && custom {
      throw ValidationError("Pass either --lightweight or --custom, not both.")
    }
  }

  var stageKind: StageKind {
    custom ? .custom : .lightweight
  }

  func run() throws {
    let context = try ProjectContext.discover()

    let nextVersion = context.latestVersion + 1
    let scaffold = Scaffolder(context: context, nextVersion: nextVersion, stageKind: stageKind)
    
    print()
    print("\u{1B}[1mScaffolding...\u{1B}[0m")
    print()

    try scaffold.run()

    let prev = context.latestVersion
    let kindLabel = stageKind == .custom ? "custom" : "lightweight"
    
    print("\u{1B}[1mSuccess ✅ Running xcodegen 🎶\u{1B}[0m")
    print()

    try scaffold.runXcodegen(at: context.repoRoot)

    var output = """

    ✓ Scaffolded V\(nextVersion) (\(kindLabel))

      Created: \(Config.schemaDirectory)/SchemaV\(nextVersion).swift
      Created: \(Config.migrationDirectory)/MigrateV\(prev)toV\(nextVersion).swift
      Created: \(Config.testsDirectory)/MigrateV\(prev)toV\(nextVersion)Tests.swift
      Updated: \(Config.migrationDirectory)/\(Config.migrationPlanFilename)
      Updated: \(scaffold.typealiasFilesUpdated.count) file(s) with bumped typealiases

    Next steps:
      1. Edit SchemaV\(nextVersion).swift to make your schema changes
      2. Fill in the test factories and assertions
    """

    if stageKind == .custom {
      output += "\n  3. Implement willMigrate / didMigrate in MigrateV\(prev)toV\(nextVersion).swift"
    }

    print(output)
  }
}

SwiftDataMigrate.main()
