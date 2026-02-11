// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import OpenID4VCI
import SwiftyJSON

struct IssuanceRouter: DeeplinkRouter {
  func route(from url: URL) async throws -> Route {
    guard let query = url.query(), query.contains("credential_offer") else {
      throw routingFailure("URL must include credential_offer")
    }

    return .issuance(credentialOfferUri: url.absoluteString)
  }
}
