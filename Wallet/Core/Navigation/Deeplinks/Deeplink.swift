import Foundation

protocol DeeplinkRouter {
  func route(from url: URL) async throws -> Route?
}

enum Deeplink {
  case issuance
  case presentation

  init?(from url: URL) {
    switch url.scheme {
      case "openid-credential-offer":
        self = .issuance
      case "openid4vp", "eudi-openid4vp":
        self = .presentation
      default:
        return nil
    }
  }

  var router: DeeplinkRouter {
    switch self {
      case .issuance:
        return IssuanceRouter()
      case .presentation:
        return PresentationRouter()
    }
  }
}
