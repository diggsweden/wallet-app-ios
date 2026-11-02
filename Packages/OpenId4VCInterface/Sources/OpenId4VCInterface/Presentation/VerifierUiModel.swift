// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

public struct VerifierUiModel: Sendable {
  public let name: String
  public let country: String
  public let descriptions: [String: String]
  public let purpose: [String: String]

  public init(
    name: String,
    country: String,
    descriptions: [String: String],
    purpose: [String: String],
  ) {
    self.name = name
    self.country = country
    self.descriptions = descriptions
    self.purpose = purpose
  }
}
