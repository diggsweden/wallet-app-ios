// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftData
import SwiftUI

enum UserStoreError: Error {
  case notFound
  case persistence(Error)
}

@ModelActor
actor UserStore: AccountIDProvider {
  func accountID() async -> String? {
    try? await getOrCreate().accountId
  }

  init() throws {
    let modelContainer = try ModelContainer(for: User.self)
    self.init(modelContainer: modelContainer)
  }

  func getOrCreate() async throws -> UserSnapshot {
    let session = try await getOrCreateModel()
    return snapshot(from: session)
  }

  func addAccountId(_ accountId: String) async throws -> UserSnapshot {
    let session = try await getOrCreateModel()
    session.accountId = accountId
    try await save()
    return snapshot(from: session)
  }

  func saveCredential(_ credential: Credential) async throws -> UserSnapshot {
    let session = try await getOrCreateModel()
    session.credential = credential
    try await save()
    return snapshot(from: session)
  }

  func deleteAll() async throws {
    do {
      try modelContext.delete(model: User.self)
      try modelContext.save()
    } catch {
      throw UserStoreError.persistence(error)
    }
  }

  private func getOrCreateModel() async throws -> User {
    if let existing = try? await fetchSession() {
      return existing
    }
    return try await createSessionModel()
  }

  private func createSessionModel() async throws -> User {
    let session = User()
    modelContext.insert(session)
    try await save()
    return session
  }

  private func fetchSession() async throws -> User? {
    do {
      return try modelContext.fetch(FetchDescriptor<User>()).first
    } catch {
      throw UserStoreError.notFound
    }
  }

  private func snapshot(from model: User) -> UserSnapshot {
    UserSnapshot(
      deviceId: model.deviceId,
      accountId: model.accountId,
      credential: model.credential
    )
  }

  private func save() async throws {
    do {
      try modelContext.save()
    } catch {
      throw UserStoreError.persistence(error)
    }
  }
}
