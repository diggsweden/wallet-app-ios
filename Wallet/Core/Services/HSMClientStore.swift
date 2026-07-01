// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import SwiftAccessMechanism

enum HSMClientStore {
  struct Config: Codable {
    let serverParameters: ServerParameters
  }

  private static let defaultsKey = "se.digg.wallet.hsmClientConfig"

  static func save(_ config: Config) throws {
    let data = try JSONEncoder().encode(config)
    UserDefaults.standard.set(data, forKey: defaultsKey)
  }

  static func load() -> Config? {
    guard let data = UserDefaults.standard.data(forKey: defaultsKey) else { return nil }
    return try? JSONDecoder().decode(Config.self, from: data)
  }
}
