import Foundation
import SiopOpenID4VP

struct PresentationRouter: DeeplinkRouter {
  func route(from url: Foundation.URL) async throws -> Route {
    let openID4VPService = try OpenID4VPService()

    let result = await openID4VPService.sdk.authorize(url: url)

    let request =
      switch result {
        case .notSecured(let request), .jwt(let request):
          request
        case .invalidResolution(let error, _):
          throw routingFailure("Failed to resolve presentation request: \(error)")
      }

    guard case let .vpToken(data) = request else {
      throw routingFailure("Unsupported presentation type, expected vp_token")
    }

    return .presentation(vpTokenData: data)
  }
}
