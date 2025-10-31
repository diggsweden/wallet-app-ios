import Foundation
import OpenID4VCI
import SwiftData

struct Disclosure: Codable, Identifiable, Hashable {
  let base64: String
  let displayName: String
  let value: String

  var id: String { base64 }
}

struct IssuerDisplay: Codable, Hashable {
  let name: String
  let info: String?
  let imageUrl: URL?
}

struct Credential: Codable, Hashable {
  let issuer: IssuerDisplay
  let sdJwt: String
  let disclosures: [String: Disclosure]
  var issuedAt: Date = .now
}
