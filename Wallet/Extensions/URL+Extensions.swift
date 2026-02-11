// SPDX-FileCopyrightText: 2026 diggsweden/wallet-app-ios
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

extension URL {
  func queryItemValue(for key: String) -> String? {
    return URLComponents(url: self, resolvingAgainstBaseURL: false)?
      .queryItems?
      .first { $0.name == key }?
      .value
  }
}
