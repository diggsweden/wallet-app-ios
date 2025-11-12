import Foundation

struct UserSnapshot: Sendable {
  let walletKeyTag: String
  let deviceKeyTag: String
  let deviceId: String
  let accountId: String?
  let walletUnitAttestation: String?
  let credential: Credential?
}
