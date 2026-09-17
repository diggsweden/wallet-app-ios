// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import AuthenticationServices
import Foundation
import SwiftUI

typealias WebAuthenticate = @MainActor (URL) async throws -> URL

extension WebAuthenticationSession {
  func handler(callbackScheme: String = "wallet-app") -> WebAuthenticate {
    { url in
      try await authenticate(
        using: url,
        callbackURLScheme: callbackScheme,
        preferredBrowserSession: .ephemeral,
      )
    }
  }
}
