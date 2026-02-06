import SwiftUI

@MainActor
@Observable
final class UserViewModel {
  enum UserStatus {
    case loading
    case ready(UserSnapshot)
    case error(String?)
  }

  var user: UserStatus = .loading
  private let userStore: UserStore

  init(userStore: UserStore) {
    self.userStore = userStore
  }

  var isEnrolled: Bool {
    guard case let .ready(user) = user else {
      return false
    }

    return user.accountId != nil && user.credential != nil
  }

  func initUser() async {
    if case .ready = user {
      return
    }

    do {
      let value = try await userStore.getOrCreate()
      user = .ready(value)
    } catch {
      user = .error(String(describing: error))
    }
  }

  func signIn(_ accountId: String) async {
    do {
      let updated = try await userStore.addAccountId(accountId)
      user = .ready(updated)
    } catch {
      user = .error(String(describing: error))
    }
  }

  func signOut() async {
    do {
      try await userStore.deleteAll()
      try KeychainService.deleteAll()
      let newuser = try await userStore.getOrCreate()
      user = .ready(newuser)
    } catch {
      user = .error(String(describing: error))
    }
  }

  func saveCredential(_ credential: Credential) async {
    do {
      let updated = try await userStore.saveCredential(credential)
      user = .ready(updated)
    } catch {
      user = .error(String(describing: error))
    }
  }
}
