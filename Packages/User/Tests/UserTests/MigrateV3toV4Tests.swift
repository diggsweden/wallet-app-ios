// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import Foundation
import SwiftData
import Testing

@testable import User

@Suite("V3 to V4 migration")
struct MigrateV3toV4Tests {
  @Test("Pid is folded into credentials and user data survives migration")
  func testMigration_fromV3ToV4_pidMovedIntoCredentials() throws {
    // given
    let userId = 1
    let accountId = "someAccountId"

    let container = try makeMigratedContainer { context in
      context.insert(
        SchemaV3.User(
          id: userId,
          accountId: accountId,
          credentials: [Self.fakeV3Credential],
          pid: Self.fakeV3Pid,
        )
      )
    }

    // when
    let user = try #require(
      try ModelContext(container)
        .fetch(
          FetchDescriptor<SchemaV4.User>()
        )
        .first
    )

    // then
    #expect(user.id == userId)
    #expect(user.accountId == accountId)
    #expect(user.credentials == [Self.fakeV4Pid, Self.fakeV4Credential])
  }

  @Test("Migration without pid leaves credentials untouched")
  func testMigration_fromV3ToV4_nilPid_credentialsUnchanged() throws {
    // given
    let container = try makeMigratedContainer { context in
      context.insert(
        SchemaV3.User(
          id: 1,
          credentials: [Self.fakeV3Credential],
        )
      )
    }

    // when
    let user = try #require(
      try ModelContext(container)
        .fetch(
          FetchDescriptor<SchemaV4.User>()
        )
        .first
    )

    // then
    #expect(user.credentials == [Self.fakeV4Credential])
  }
}

private extension MigrateV3toV4Tests {
  func makeMigratedContainer(populate: (ModelContext) throws -> Void) throws -> ModelContainer {
    let url = FileManager.default.temporaryDirectory
      .appending(path: "test-\(UUID().uuidString).store")

    let container = try ModelContainer(
      for: SchemaV3.User.self,
      configurations: ModelConfiguration(url: url),
    )

    let context = ModelContext(container)
    try populate(context)
    try context.save()

    return try ModelContainer(
      for: SchemaV4.User.self,
      migrationPlan: SwiftDataMigrationPlan.self,
      configurations: ModelConfiguration(url: url),
    )
  }

  static let fakeV3Credential = SchemaV3.SavedCredential(
    issuer: SchemaV3.IssuerDisplay(
      name: "Some Issuer",
      info: "Some Info",
      imageUrl: nil,
    ),
    compactSerialized: "someSerialization",
    claimDisplayNames: ["abc": "123"],
    claimsCount: 1,
    issuedAt: .init(timeIntervalSince1970: 1),
    type: "Document",
    displayData: SchemaV3.CredentialDisplayData(name: "Some Credential"),
  )

  static let fakeV4Credential = SchemaV4.SavedCredential(
    issuer: SchemaV4.IssuerDisplay(
      name: "Some Issuer",
      info: "Some Info",
      imageUrl: nil,
    ),
    compactSerialized: "someSerialization",
    claimDisplayNames: ["abc": "123"],
    claimsCount: 1,
    issuedAt: .init(timeIntervalSince1970: 1),
    type: "Document",
    displayData: SchemaV4.CredentialDisplayData(name: "Some Credential"),
  )

  static let fakeV3Pid = SchemaV3.SavedCredential(
    issuer: SchemaV3.IssuerDisplay(
      name: "Digg",
      info: "ID-stuff",
      imageUrl: nil,
    ),
    compactSerialized: "Some Info",
    claimDisplayNames: ["abc": "123"],
    claimsCount: 1,
    issuedAt: .init(timeIntervalSince1970: 1),
    type: CredentialType.pid.rawValue,
    displayData: SchemaV3.CredentialDisplayData(name: "PID"),
  )

  static let fakeV4Pid = SchemaV4.SavedCredential(
    issuer: SchemaV4.IssuerDisplay(
      name: "Digg",
      info: "ID-stuff",
      imageUrl: nil,
    ),
    compactSerialized: "Some Info",
    claimDisplayNames: ["abc": "123"],
    claimsCount: 1,
    issuedAt: .init(timeIntervalSince1970: 1),
    type: CredentialType.pid.rawValue,
    displayData: SchemaV4.CredentialDisplayData(name: "PID"),
  )
}
