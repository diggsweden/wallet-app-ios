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

  var isEnrolled: Bool {
    guard case let .ready(user) = user else {
      return false
    }
    return user.accountId != nil
      && user.walletUnitAttestation != nil
      && user.credential != nil
  }

  init(userStore: UserStore) {
    self.userStore = userStore
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
      try CryptoKeyStore.shared.deleteAll()
      let newuser = try await userStore.getOrCreate()
      user = .ready(newuser)
    } catch {
      user = .error(String(describing: error))
    }
  }

  func setKeyAttestation(_ attestation: String) async {
    do {
      let updated = try await userStore.addKeyAttestation(attestation)
      user = .ready(updated)
    } catch {
      user = .error(String(describing: error))
    }
  }

  func setCredential(_ credential: Credential) async {
    do {
      let updated = try await userStore.addCredential(credential)
      user = .ready(updated)
    } catch {
      user = .error(String(describing: error))
    }
  }
}
