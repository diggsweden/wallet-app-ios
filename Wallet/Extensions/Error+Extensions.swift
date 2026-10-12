// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import AuthenticationServices
import Foundation

extension Error {
  var message: String {
    (self as? LocalizedError)?.errorDescription ?? self.localizedDescription
  }

  var isWebAuthCancellation: Bool {
    (self as? ASWebAuthenticationSessionError)?.code == .canceledLogin
  }

  func toErrorEvent() -> ErrorEvent {
    .init(self.message)
  }
}
