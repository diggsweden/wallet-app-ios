// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Jose

public struct ProofKey: Sendable, Equatable {
  public struct ID: Hashable, Sendable, RawRepresentable, Codable {
    public let rawValue: String

    public init(rawValue: String) {
      self.rawValue = rawValue
    }

    public init(_ rawValue: String) {
      self.rawValue = rawValue
    }
  }
  public let id: ID
  public let publicKey: WalletJoseJWK

  public init(id: ID, publicKey: WalletJoseJWK) {
    self.id = id
    self.publicKey = publicKey
  }
}
