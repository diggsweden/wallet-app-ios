import Foundation
import OpenID4VCI
import SwiftyJSON

struct IssuanceRouter: DeeplinkRouter {
  func route(from url: URL) async throws -> Route? {
    guard let query = url.query(), query.contains("credential_offer") else {
      return nil
    }

    return .issuance(credentialOfferUri: url.absoluteString)
  }
}
