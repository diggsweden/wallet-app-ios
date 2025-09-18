import Foundation
import SwiftData

@Model
class User {
  @Attribute(.unique) var id = 0
  var email: String
  var pin: String
  var phoneNumber: String?

  init(email: String, pin: String, phoneNumber: String?) {
    self.email = email
    self.pin = pin
    self.phoneNumber = phoneNumber
  }
}

@Model
class Wallet {
  @Attribute(.unique) var id = 0
  var unitId: UUID = UUID()
  var unitAttestation: String?
  var credential: Credential?

  init(unitAttestation: String? = nil, credential: Credential? = nil) {
    self.unitAttestation = unitAttestation
    self.credential = credential
  }
}
