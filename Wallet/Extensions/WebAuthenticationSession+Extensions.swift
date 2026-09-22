// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import AuthenticationServices
import Foundation
import SwiftUI

/// Returns the callback URL, or `nil` if the user cancelled the web session.
typealias WebAuthenticate = @MainActor (URL) async throws -> URL?

extension WebAuthenticationSession {
  func handler(callbackScheme: String = "wallet-app") -> WebAuthenticate {
    { url in
      do {
        return try await authenticate(
          using: url,
          callbackURLScheme: callbackScheme,
          preferredBrowserSession: .ephemeral,
        )
      } catch where error.isWebAuthCancellation {
        return nil
      }
    }
  }
}
