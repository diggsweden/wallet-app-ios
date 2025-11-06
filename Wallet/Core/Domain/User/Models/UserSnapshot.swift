import Foundation

struct UserSnapshot: Sendable {
  let keyTag: UUID
  let deviceId: UUID
  let userProfile: UserProfile?
  let walletUnitAttestation: String?
  let credential: Credential?
}
