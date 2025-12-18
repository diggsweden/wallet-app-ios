import Foundation

protocol DeeplinkRouter {
  func route(from url: URL) async throws -> Route
}

extension DeeplinkRouter {
  func routingFailure(_ reason: String) -> DeeplinkError {
    return .routingFailure(routerName: String(describing: Self.self), reason: reason)
  }
}

enum Deeplink {
  case issuance
  case presentation
  case walletApp

  init(from url: URL) throws {
    switch url.scheme {
      case "openid-credential-offer":
        self = .issuance
      case "openid4vp", "eudi-openid4vp":
        self = .presentation
      case "wallet-app":
        self = .walletApp
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
      case .walletApp:
        return WalletAppRouter()
    }
  }
}

private struct WalletAppRouter: DeeplinkRouter {
  func route(from url: URL) async throws -> Route {
    print(url)
    return .settings
  }
}
