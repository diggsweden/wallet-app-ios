// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

public enum ClaimPathElement: Hashable, Sendable {
  case claim(name: String)
  case arrayElement(index: Int)
  case allArrayElements
}

public struct ClaimPath: Hashable, Sendable {
  public let elements: [ClaimPathElement]

  public init(_ elements: [ClaimPathElement]) {
    self.elements = elements
  }
}
