// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

extension Bundle {
  static func urlSchemes(in infoDictionary: [String: Any]?) -> Set<String> {
    let types = infoDictionary?["CFBundleURLTypes"] as? [[String: Any]] ?? []
    return Set(
      types
        .flatMap { $0["CFBundleURLSchemes"] as? [String] ?? [] }
        .map { $0.lowercased() }
    )
  }
}
