// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import AuthenticationServices
import Foundation
import SwiftUI

struct WebAuthRequest {
  let url: URL
  let callbackScheme: String
}

/// Returns the callback URL, or `nil` if the user cancelled the web session.
typealias WebAuthenticator = @MainActor (WebAuthRequest) async throws -> URL?

extension WebAuthenticationSession {
  var authenticator: WebAuthenticator {
    { request in
      do {
        return try await authenticate(
          using: request.url,
          callback: .customScheme(request.callbackScheme),
          preferredBrowserSession: .ephemeral,
          additionalHeaderFields: [:],
        )
      } catch  where error.isWebAuthCancellation {
        return nil
      }
    }
  }
}
