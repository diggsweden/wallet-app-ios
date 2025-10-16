import SwiftData
import SwiftUI

enum SessionError: Error {
  case notFound
  case persistence(Error)
}

@ModelActor
actor SessionStore {
  init() throws {
    let modelContainer = try ModelContainer(for: AppSession.self)
    self.init(modelContainer: modelContainer)
  }

  func getOrCreate() async throws -> AppSession {
    if let existing = try? await fetchSession() {
      return existing
    }
    return try await createSession()
  }

  func addUser(_ user: User) async throws -> AppSession {
    let session = try await getOrCreate()
    session.user = user
    try await save()
    return session
  }

  func addCredential(_ credential: Credential) async throws -> AppSession {
    let session = try await getOrCreate()
    session.credential = credential
    try await save()
    return session
  }

  func addKeyAttestation(_ keyAttestation: String) async throws -> AppSession {
    let session = try await getOrCreate()
    session.walletUnitAttestation = keyAttestation
    try await save()
    return session
  }

  func deleteAll() async throws {
    do {
      try modelContext.delete(model: AppSession.self)
      try modelContext.save()
    } catch {
      throw SessionError.persistence(error)
    }
  }

  private func createSession() async throws -> AppSession {
    let session = AppSession()
    modelContext.insert(session)
    try await save()
    return session
  }

  private func fetchSession() async throws -> AppSession? {
    do {
      return try modelContext.fetch(FetchDescriptor<AppSession>()).first
    } catch {
      throw SessionError.notFound
    }
  }

  private func save() async throws {
    do {
      try modelContext.save()
    } catch {
      throw SessionError.persistence(error)
    }
  }
}
