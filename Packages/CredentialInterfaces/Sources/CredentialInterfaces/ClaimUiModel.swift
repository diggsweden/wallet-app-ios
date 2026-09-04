// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

public enum ClaimValue: Sendable {
  case string(String)
  case date(Date)
  case int(Int)
  case double(Double)
  case bool(Bool)
  case null
  case array([ClaimUiModel])
  case object([ClaimUiModel])
  case imageData(Data)
}

public struct ClaimUiModel: Identifiable, Sendable {
  public let id: String
  public let displayName: String?
  public let value: ClaimValue

  public init(
    id: String,
    displayName: String?,
    value: ClaimValue,
  ) {
    self.id = id
    self.displayName = displayName
    self.value = value
  }
}
