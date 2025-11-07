import Foundation
import SwiftData

@Model
final class User {
  @Attribute(.unique) var id = 0
  var keyTag: UUID = UUID()
  var deviceId: UUID = UUID()
  var accountId: String?
  var walletUnitAttestation: String?
  var credential: Credential?

  init() {}
}
