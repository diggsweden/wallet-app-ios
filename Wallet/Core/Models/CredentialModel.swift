import Foundation
import OpenID4VCI
import SwiftData

struct Disclosure: Codable, Identifiable, Hashable {
  let base64: String
  let claim: Claim
  let value: String

  var id: String { base64 }
}

struct Credential: Codable, Hashable {
  let issuer: Display?
  let sdJwt: String
  let disclosures: [String: Disclosure]
  var issuedAt: Date = .now
}
