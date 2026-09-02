// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces

public struct IssuedCredential: Sendable {
  public let credential: SavedCredential
  public let claims: [ClaimUiModel]

  public init(credential: SavedCredential, claims: [ClaimUiModel]) {
    self.credential = credential
    self.claims = claims
  }
}
