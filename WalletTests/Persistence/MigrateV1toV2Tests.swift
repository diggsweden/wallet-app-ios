// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import SwiftData
import Testing

@testable import WalletDemo

@Suite("V1 to V2 migration")
struct MigrateV1toV2Tests {
  @Test("Task survives migration with data intact")
  func testMigration_fromV1ToV2_dataIntact() throws {
    // given
    let userId = 1
    let deviceId = "someDeviceId"
    let accountId = "someAccountId"

    let container = try makeMigratedContainer { context in
      context.insert(
        SchemaV1.User(
          id: userId,
          deviceId: deviceId,
          accountId: accountId,
          credentials: [Self.fakeV1Credential],
          pid: Self.fakeV1Pid
        )
      )
    }

    // when
    let user = try #require(
      try ModelContext(container)
        .fetch(
          FetchDescriptor<SchemaV2.User>()
        )
        .first
    )

    // then
    #expect(user.id == userId)
    #expect(user.accountId == accountId)
    #expect(user.credentials.first == MigrateV1toV2Tests.fakeV2Credential)
    #expect(user.pid == MigrateV1toV2Tests.fakeV2Pid)
  }
}

private extension MigrateV1toV2Tests {
  func makeMigratedContainer(populate: (ModelContext) throws -> Void) throws -> ModelContainer {
    let url = FileManager.default.temporaryDirectory
      .appending(path: "test-\(UUID().uuidString).store")

    let container = try ModelContainer(
      for: SchemaV1.User.self,
      configurations: ModelConfiguration(url: url)
    )

    let context = ModelContext(container)
    try populate(context)
    try context.save()

    return try ModelContainer(
      for: SchemaV2.User.self,
      migrationPlan: SwiftDataMigrationPlan.self,
      configurations: ModelConfiguration(url: url)
    )
  }

  static let fakeV1Credential = SchemaV1.SavedCredential(
    issuer: SchemaV1.IssuerDisplay(
      name: "Some Issuer",
      info: "Some Info",
      imageUrl: nil
    ),
    compactSerialized: "someSerialization",
    claimDisplayNames: ["abc": "123"],
    claimsCount: 1,
    issuedAt: .init(timeIntervalSince1970: 1),
    type: "Document",
    displayData: SchemaV1.CredentialDisplayData(name: "Some Credential")
  )

  static let fakeV2Credential = SchemaV2.SavedCredential(
    issuer: SchemaV2.IssuerDisplay(
      name: "Some Issuer",
      info: "Some Info",
      imageUrl: nil
    ),
    compactSerialized: "someSerialization",
    claimDisplayNames: ["abc": "123"],
    claimsCount: 1,
    issuedAt: .init(timeIntervalSince1970: 1),
    type: "Document",
    displayData: SchemaV2.CredentialDisplayData(name: "Some Credential")
  )

  static let fakeV1Pid = SchemaV1.SavedCredential(
    issuer: SchemaV1.IssuerDisplay(
      name: "Digg",
      info: "ID-stuff",
      imageUrl: nil
    ),
    compactSerialized: "Some Info",
    claimDisplayNames: ["abc": "123"],
    claimsCount: 1,
    issuedAt: .init(timeIntervalSince1970: 1),
    type: SchemaV1.CredentialType.pid.rawValue,
    displayData: SchemaV1.CredentialDisplayData(name: "PID")
  )

  static let fakeV2Pid = SchemaV2.SavedCredential(
    issuer: SchemaV2.IssuerDisplay(
      name: "Digg",
      info: "ID-stuff",
      imageUrl: nil
    ),
    compactSerialized: "Some Info",
    claimDisplayNames: ["abc": "123"],
    claimsCount: 1,
    issuedAt: .init(timeIntervalSince1970: 1),
    type: SchemaV2.CredentialType.pid.rawValue,
    displayData: SchemaV2.CredentialDisplayData(name: "PID")
  )
}
