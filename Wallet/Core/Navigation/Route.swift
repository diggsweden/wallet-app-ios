import Foundation
import SiopOpenID4VP

enum Route: Hashable, Codable {
  case presentation(definition: PresentationDefinition)
  case issuance(credentialOfferUri: String)
}
