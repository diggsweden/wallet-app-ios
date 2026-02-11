// SPDX-FileCopyrightText: 2026 diggsweden/wallet-app-ios
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

enum URLError: LocalizedError {
  case notStringLiteral, malformedUrl
  var localizedDescription: String {
    switch self {
      case .notStringLiteral: return "URLMacro requires a static string literal"
      case .malformedUrl: return "malformed url"
    }
  }
}

public enum URLMacro: ExpressionMacro {
  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) throws -> ExprSyntax {
    guard
      let argument = node.arguments.first?.expression,
      let segments = argument.as(StringLiteralExprSyntax.self)?.segments,
      segments.count == 1,
      case .stringSegment(let literalSegment)? = segments.first
    else {
      throw URLError.notStringLiteral
    }

    guard URL(string: literalSegment.content.text) != nil else {
      throw URLError.malformedUrl
    }

    return "URL(string: \(argument))!"
  }
}
