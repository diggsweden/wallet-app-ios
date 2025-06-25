import Foundation

struct IssuanceRouter: DeeplinkRouter {
  func route(from url: URL) async throws -> Route? {
    guard let uri = url.queryItemValue(for: "credential_offer_uri") else {
      return nil
    }
    
    return .issuance(credentialOfferUri: uri)
  }
}
