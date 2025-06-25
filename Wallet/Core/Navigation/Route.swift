import Foundation

enum Route: Hashable, Codable {
  case issuance(credentialOfferUri: String)
}
