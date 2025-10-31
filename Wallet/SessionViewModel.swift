import SwiftUI

@Observable
final class SessionViewModel {
  enum SessionStatus {
    case loading
    case ready(AppSession)
    case error(String?)
  }

  var session: SessionStatus = .loading
  private let sessionStore: SessionStore

  var isEnrolled: Bool {
    guard case let .ready(appSession) = session else {
      return false
    }
    return appSession.user != nil && appSession.walletUnitAttestation != nil
      && appSession.credential != nil
  }

  init(sessionStore: SessionStore) {
    self.sessionStore = sessionStore
  }

  func initSession() async {
    if case .ready = session {
      return
    }

    do {
      let value = try await sessionStore.getOrCreate()
      session = .ready(value)
    } catch {
      session = .error(String(describing: error))
    }
  }

  func signIn(_ user: User) async {
    do {
      let updated = try await sessionStore.addUser(user)
      session = .ready(updated)
    } catch {
      session = .error(String(describing: error))
    }
  }

  func signOut() async {
    do {
      try await sessionStore.deleteAll()
      let newSession = try await sessionStore.getOrCreate()
      session = .ready(newSession)
    } catch {
      session = .error(String(describing: error))
    }
  }

  func setKeyAttestation(_ attestation: String) async {
    do {
      let updated = try await sessionStore.addKeyAttestation(attestation)
      session = .ready(updated)
    } catch {
      session = .error(String(describing: error))
    }
  }

  func setCredential(_ credential: Credential) async {
    do {
      let updated = try await sessionStore.addCredential(credential)
      session = .ready(updated)
    } catch {
      session = .error(String(describing: error))
    }
  }
}
