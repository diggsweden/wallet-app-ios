import Foundation
import SwiftData

@Model
final class AppSession {
  @Attribute(.unique) var id = 0
  var keyTag: UUID = UUID()
  var user: User?
  var wallet: Wallet = Wallet()

  init(user: User? = nil) {
    self.user = user
  }
}

struct User: Codable {
  var email: String
  var pin: String
  var phoneNumber: String?

  init(email: String, pin: String, phoneNumber: String? = nil) {
    self.email = email
    self.pin = pin
    self.phoneNumber = phoneNumber
  }
}

@Model
class Wallet {
  var unitId: UUID = UUID()
  var unitAttestation: String?
  var credential: Credential?

  init(unitAttestation: String? = nil, credential: Credential? = nil) {
    self.unitAttestation = unitAttestation
    self.credential = credential
  }
}
