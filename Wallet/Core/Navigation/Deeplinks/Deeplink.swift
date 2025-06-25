import Foundation

protocol DeeplinkRouter {
  func route(from url: URL) async throws -> Route?
}

enum Deeplink {
  case issuance

  init?(from url: URL) {
    switch url.scheme {
      case "openid-credential-offer":
        self = .issuance
      default:
        return nil
    }
  }

  var router: DeeplinkRouter {
    switch self {
      case .issuance:
        return IssuanceRouter()
    }
  }
}
