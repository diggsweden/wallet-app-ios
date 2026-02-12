// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import HTTPTypes

extension HTTPRequest {
  mutating func setHeader(_ key: String, _ value: String) {
    guard let keyField = HTTPField.Name(key) else {
      return
    }

    headerFields[keyField] = value
  }
}
