// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import SwiftAccessMechanism
import SwiftUI
import User

@MainActor
@Observable
final class UserSessionViewModel {
  enum UserStatus: Equatable {
    case loading
    case ready(UserSnapshot)
    case error(CaughtError)
  }

  private(set) var user: UserStatus = .loading
  private let userStore: UserStore

  init(userStore: UserStore) {
    self.userStore = userStore
  }

  var userSnapshot: UserSnapshot? {
    if case .ready(let snapshot) = user {
      return snapshot
    }
    return nil
  }

  var isEnrolled: Bool {
    guard case let .ready(user) = user else {
      return false
    }

    return user.accountId != nil && user.pid != nil
  }

  func initUser() async {
    if case .ready = user {
      return
    }

    do {
      let value = try await userStore.getOrCreate()
      user = .ready(value)
    } catch {
      user = .error(CaughtError(error))
    }
  }

  func retryInitUser() async {
    user = .loading
    await initUser()
  }

  func signIn(_ accountId: String) async throws {
    let updated = try await userStore.addAccountId(accountId)
    user = .ready(updated)
  }

  func signOut() async throws {
    try await userStore.deleteAll()
    try SecKeyStore.deleteAll()
    try SigningKeyStore.deleteAll()
    let newUser = try await userStore.getOrCreate()
    user = .ready(newUser)
  }

  func savePid(_ credential: SavedCredential) async throws {
    let updated = try await userStore.savePid(credential)
    user = .ready(updated)
  }

  func saveCredential(_ credential: SavedCredential) async throws {
    let updated = try await userStore.addCredential(credential)
    user = .ready(updated)
  }

  func saveHsmServerParameters(_ parameters: ServerParameters) async throws {
    let updated = try await userStore.saveHsmServerParameters(HsmServerParameters(parameters))
    user = .ready(updated)
  }
}
