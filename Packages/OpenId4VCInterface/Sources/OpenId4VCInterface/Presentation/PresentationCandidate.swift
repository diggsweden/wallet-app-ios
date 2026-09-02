// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces

public struct PresentationCandidate: Identifiable, Sendable {
  public let id: String
  public let required: Bool
  public let claims: [ClaimUiModel]

  public init(id: String, required: Bool, claims: [ClaimUiModel]) {
    self.id = id
    self.required = required
    self.claims = claims
  }
}
