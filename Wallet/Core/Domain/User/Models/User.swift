import Foundation
import SwiftData

@Model
final class User {
  @Attribute(.unique) var id = 0
  var walletKeyTag: String = UUID().uuidString
  var deviceKeyTag: String = UUID().uuidString
  var deviceId: String = UUID().uuidString
  var accountId: String?
  var walletUnitAttestation: String?
  var credential: Credential?

  init() {}
}
