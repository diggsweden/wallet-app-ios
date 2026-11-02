// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces

public struct RequestableCredential: Equatable, Sendable {
  public let format: String
  public let vctValues: Set<String>
  public let claimPaths: Set<ClaimPath>

  public init(
    format: String,
    vctValues: Set<String>,
    claimPaths: Set<ClaimPath>,
  ) {
    self.format = format
    self.vctValues = vctValues
    self.claimPaths = claimPaths
  }
}
