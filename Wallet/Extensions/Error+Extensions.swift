// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

extension Error {
  var message: String {
    return (self as? LocalizedError)?.errorDescription ?? self.localizedDescription
  }

  func toErrorEvent() -> ErrorEvent {
    return .init(self.message)
  }
}
