// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

public enum ClaimPathElement: Hashable, Sendable, Codable {
  case claim(name: String)
  case arrayElement(index: Int)
  case allArrayElements

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if container.decodeNil() {
      self = .allArrayElements
    } else if let index = try? container.decode(Int.self) {
      self = .arrayElement(index: index)
    } else {
      self = .claim(name: try container.decode(String.self))
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
      case .claim(let name): try container.encode(name)
      case .arrayElement(let index): try container.encode(index)
      case .allArrayElements: try container.encodeNil()
    }
  }
}

public struct ClaimPath: Hashable, Sendable, Codable {
  public let elements: [ClaimPathElement]

  public init(_ elements: [ClaimPathElement]) {
    self.elements = elements
  }

  public init(from decoder: Decoder) throws {
    self.init(try decoder.singleValueContainer().decode([ClaimPathElement].self))
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(elements)
  }
}
