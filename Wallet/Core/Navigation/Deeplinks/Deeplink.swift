import Foundation

protocol DeeplinkRouter {
  func route(from url: URL) async throws -> Route
}

extension DeeplinkRouter {
  func routingFailure(_ reason: String) -> DeeplinkError {
    return .routingFailure(router: Self.self, reason: reason)
  }
}

enum Deeplink {
  case issuance
  case presentation

  init(from url: URL) throws {
    switch url.scheme {
      case "openid-credential-offer":
        self = .issuance
      case "openid4vp", "eudi-openid4vp":
        self = .presentation
      default:
        throw DeeplinkError.invalidScheme
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
