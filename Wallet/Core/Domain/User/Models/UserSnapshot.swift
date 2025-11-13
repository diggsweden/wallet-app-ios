import Foundation

struct UserSnapshot: Sendable {
  let deviceId: String
  let accountId: String?
  let walletUnitAttestation: String?
  let credential: Credential?
}
