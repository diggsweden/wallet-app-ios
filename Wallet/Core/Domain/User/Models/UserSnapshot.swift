import Foundation

struct UserSnapshot: Sendable {
  let keyTag: UUID
  let deviceId: UUID
  let accountId: String?
  let walletUnitAttestation: String?
  let credential: Credential?
}
