import Foundation
import SwiftData

@Model
final class AppSession {
  @Attribute(.unique) var id = 0
  var keyTag: UUID = UUID()
  var deviceId: UUID = UUID()
  var user: User?
  var walletUnitAttestation: String?
  var credential: Credential?

  init(user: User? = nil) {
    self.user = user
  }
}

struct User: Codable {
  let email: String
  let pin: String
  let phoneNumber: String?
}
