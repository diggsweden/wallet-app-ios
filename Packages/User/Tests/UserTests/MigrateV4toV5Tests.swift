// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import Foundation
import SwiftData
import Testing

@testable import User

@Suite("V4 to V5 migration", .serialized)
struct MigrateV4toV5Tests {
  @Test("Existing users are marked for reset and the flag survives reopening the store")
  // swiftlint:disable:next function_body_length
  func marksExistingUserForReset() throws {
    let credentials = [
      Self.credential(type: "Document", compactSerialized: "document"),
      Self.credential(
        type: CredentialType.pid.rawValue,
        compactSerialized: "legacy-pid",
      ),
    ]
    let parameters = SchemaV4.HsmServerParameters(
      serverJwsPublicKey: .init(kty: "EC", crv: "P-256", x: "x", y: "y", kid: "server-key"),
      opaqueContext: Data([1, 2]),
      opaqueServerIdentifier: Data([3, 4]),
    )

    // swiftlint:disable:next closure_body_length
    try withStore { url in
      try createV4Store(at: url) { context in
        context.insert(
          SchemaV4.User(
            id: 1,
            accountId: "account",
            credentials: credentials,
            hsmServerParameters: parameters,
          )
        )
      }
      do {
        let container = try migrateStore(at: url)
        let user = try #require(
          try ModelContext(container).fetch(FetchDescriptor<SchemaV5.User>()).first
        )
        #expect(user.id == 1)
        #expect(user.accountId == "account")
        #expect(!user.isOnboardingCompleted)
        #expect(user.isReset)
        #expect(user.backendGeneration == nil)
        #expect(user.hsmServerParameters?.serverJwsPublicKey.kid == "server-key")
        #expect(user.hsmServerParameters?.opaqueContext == parameters.opaqueContext)
        #expect(
          user.hsmServerParameters?.opaqueServerIdentifier == parameters.opaqueServerIdentifier
        )
        #expect(user.credentials.map(\.keyId) == ["", ""])
        // Decoding as V4 ignores the new field and checks every original credential field.
        let originalValues = try JSONDecoder()
          .decode(
            [SchemaV4.SavedCredential].self,
            from: JSONEncoder().encode(user.credentials),
          )
        #expect(originalValues == credentials)
      }
      let reopened = try ModelContainer(
        for: SchemaV5.User.self,
        configurations: ModelConfiguration(url: url),
      )
      let user = try #require(
        try ModelContext(reopened).fetch(FetchDescriptor<SchemaV5.User>()).first
      )
      #expect(user.credentials.map(\.keyId) == ["", ""])
      #expect(!user.isOnboardingCompleted)
      #expect(user.isReset)
      #expect(user.backendGeneration == nil)
    }
  }

  @Test("A user without credentials can migrate without a PID")
  func emptyCredentials() throws {
    try withStore { url in
      try createV4Store(at: url) { $0.insert(SchemaV4.User()) }
      let container = try migrateStore(at: url)
      let user = try #require(
        try ModelContext(container).fetch(FetchDescriptor<SchemaV5.User>()).first
      )
      #expect(user.credentials.isEmpty)
      #expect(!user.isOnboardingCompleted)
      #expect(user.isReset)
      #expect(user.backendGeneration == nil)
    }
  }

  @Test(
    "Legacy credentials migrate without requiring a valid PID",
    arguments: [CredentialType.pid.rawValue, "Document"],
  )
  func legacyCredentials(type: String) throws {
    try withStore { url in
      try createV4Store(at: url) { context in
        context.insert(
          SchemaV4.User(credentials: [
            Self.credential(type: type, compactSerialized: "invalid")
          ])
        )
      }
      let container = try migrateStore(at: url)
      let user = try #require(
        try ModelContext(container).fetch(FetchDescriptor<SchemaV5.User>()).first
      )
      #expect(user.isReset)
      #expect(user.credentials.first?.compactSerialized == "invalid")
    }
  }

  @Test("New V5 users do not need a reset")
  func newUser() throws {
    try withStore { url in
      let container = try migrateStore(at: url)
      let context = ModelContext(container)
      let user = SchemaV5.User()
      context.insert(user)
      try context.save()
      #expect(!user.isReset)
      #expect(user.backendGeneration == nil)
    }
  }

  @Test("The integer backend generation survives reopening", arguments: [0, 42])
  func backendGenerationIsPersisted(generation: Int) throws {
    try withStore { url in
      do {
        let container = try migrateStore(at: url)
        let context = ModelContext(container)
        context.insert(SchemaV5.User(backendGeneration: generation))
        try context.save()
      }
      let reopened = try migrateStore(at: url)
      let user = try #require(
        try ModelContext(reopened).fetch(FetchDescriptor<SchemaV5.User>()).first
      )
      #expect(user.backendGeneration == generation)
      #expect(!user.isReset)
    }
  }
}

private extension MigrateV4toV5Tests {
  func withStore(_ body: (URL) throws -> Void) throws {
    let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: directory) }
    try body(directory.appending(path: "user.store"))
  }

  func createV4Store(at url: URL, populate: (ModelContext) throws -> Void) throws {
    let container = try ModelContainer(
      for: SchemaV4.User.self,
      configurations: ModelConfiguration(url: url),
    )
    let context = ModelContext(container)
    try populate(context)
    try context.save()
  }

  func migrateStore(at url: URL) throws -> ModelContainer {
    try ModelContainer(
      for: SchemaV5.User.self,
      migrationPlan: SwiftDataMigrationPlan.self,
      configurations: ModelConfiguration(url: url),
    )
  }

  static func credential(type: String, compactSerialized: String) -> SchemaV4.SavedCredential {
    SchemaV4.SavedCredential(
      issuer: .init(
        name: "Issuer",
        info: "Info",
        imageUrl: URL(string: "https://example.com/logo.png"),
      ),
      compactSerialized: compactSerialized,
      claimDisplayNames: ["given_name": "Name"],
      claimsCount: 1,
      issuedAt: Date(timeIntervalSince1970: 123),
      type: type,
      displayData: .init(name: "Credential"),
    )
  }
}
