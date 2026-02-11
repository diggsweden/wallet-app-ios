// SPDX-FileCopyrightText: 2026 diggsweden/wallet-app-ios
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import OpenID4VP

struct PresentationRouter: DeeplinkRouter {
  func route(from url: Foundation.URL) async throws -> Route {
    let openID4VPService = try OpenID4VPService()

    let result = await openID4VPService.sdk.authorize(url: url)

    let resolvedRequest =
      switch result {
        case .notSecured(let request), .jwt(let request):
          request
        case .invalidResolution(let error, _):
          throw routingFailure("Failed to resolve presentation request: \(error)")
      }

    return .presentation(vpTokenData: resolvedRequest.request)
  }
}
