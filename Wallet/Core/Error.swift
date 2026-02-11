// SPDX-FileCopyrightText: 2026 diggsweden/wallet-app-ios
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

struct AppError: LocalizedError {
  let reason: String
  var errorDescription: String? {
    return reason
  }
}

struct ErrorEvent: Identifiable, Equatable {
  let id = UUID()
  let message: String

  init(_ message: String) {
    self.message = message
  }
}
