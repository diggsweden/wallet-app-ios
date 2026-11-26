// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import Foundation

public struct CredentialUiModel: Sendable {
  public let type: String
  public let name: String?
  public let issuerLogoUrl: URL?
  public let claims: [ClaimUiModel]

  public init(
    type: String,
    name: String?,
    issuerLogoUrl: URL? = nil,
    claims: [ClaimUiModel],
  ) {
    self.type = type
    self.name = name
    self.issuerLogoUrl = issuerLogoUrl
    self.claims = claims
  }
}
