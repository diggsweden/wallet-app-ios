// SPDX-FileCopyrightText: 2026 diggsweden/wallet-app-ios
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

extension String {
  var utf8Data: Data {
    // swift-format-ignore
    return self.data(using: .utf8)!
  }
}
