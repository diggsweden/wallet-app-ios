import Foundation
import SwiftData

@Model
final class User {
  @Attribute(.unique) var id = 0
  var keyTag: UUID = UUID()
  var deviceId: UUID = UUID()
  var userProfile: UserProfile?
  var walletUnitAttestation: String?
  var credential: Credential?

  init(user: UserProfile? = nil) {
    self.userProfile = user
  }
}
