// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

extension String {
  var utf8Data: Data {
    // swift-format-ignore
    return self.data(using: .utf8)!
  }
}
