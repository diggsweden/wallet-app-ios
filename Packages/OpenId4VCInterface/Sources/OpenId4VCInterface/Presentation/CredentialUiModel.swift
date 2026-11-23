// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces

public struct CredentialUiModel: Sendable {
  public let type: String
  public let name: String?
  public let claims: [ClaimUiModel]

  public init(type: String, name: String?, claims: [ClaimUiModel]) {
    self.type = type
    self.name = name
    self.claims = claims
  }
}
