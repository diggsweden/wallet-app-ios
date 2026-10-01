// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

public struct DisclosedCredential: Sendable {
  public let serialisation: String
  public let bindingKeyId: ProofKey.ID

  public init(serialisation: String, bindingKeyId: ProofKey.ID) {
    self.serialisation = serialisation
    self.bindingKeyId = bindingKeyId
  }
}
