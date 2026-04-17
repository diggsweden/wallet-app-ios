// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import SwiftData

enum UserStoreError: Error {
  case notFound
  case persistence(Error)
  case invalidPidCredential
}

@ModelActor
actor UserStore: AccountIdProvider {
  func accountId() -> String? {
    try? getOrCreate().accountId
  }

  init() throws {
    let modelContainer = try ModelContainer(for: User.self)
    self.init(modelContainer: modelContainer)
  }

  func getOrCreate() throws -> UserSnapshot {
    let session = try getOrCreateModel()
    return snapshot(from: session)
  }

  func addAccountId(_ accountId: String) throws -> UserSnapshot {
    let session = try getOrCreateModel()
    session.accountId = accountId
    try save()
    return snapshot(from: session)
  }

  func savePid(_ credential: SavedCredential) throws -> UserSnapshot {
    guard credential.type == CredentialType.pid.rawValue else {
      throw UserStoreError.invalidPidCredential
    }
    let user = try getOrCreateModel()
    user.pid = credential
    try save()
    return snapshot(from: user)
  }

  func addCredential(_ credential: SavedCredential) throws -> UserSnapshot {
    let user = try getOrCreateModel()
    user.credentials.append(credential)
    try save()
    return snapshot(from: user)
  }

  func deleteAll() throws {
    try modelContext.delete(model: User.self)
    try save()
  }

  private func getOrCreateModel() throws -> User {
    if let existing = try fetchSession() {
      return existing
    }
    return try createSessionModel()
  }

  private func createSessionModel() throws -> User {
    let session = User()
    modelContext.insert(session)
    try save()
    return session
  }

  private func fetchSession() throws -> User? {
    do {
      return try modelContext.fetch(FetchDescriptor<User>()).first
    } catch {
      throw UserStoreError.persistence(error)
    }
  }

  private func snapshot(from model: User) -> UserSnapshot {
    UserSnapshot(
      deviceId: model.deviceId,
      accountId: model.accountId,
      credentials: model.credentials,
      pid: model.pid
    )
  }

  private func save() throws {
    do {
      try modelContext.save()
    } catch {
      throw UserStoreError.persistence(error)
    }
  }
}
