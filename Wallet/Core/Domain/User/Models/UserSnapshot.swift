import Foundation

struct UserSnapshot: Sendable {
  let deviceId: String
  let accountId: String?
  let credential: Credential?
}
