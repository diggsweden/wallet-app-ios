// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import SwiftyJSON
import eudi_lib_sdjwt_swift

extension SignedSDJWT {
  private static let reservedClaims: Set<String> = [
    "iss", "sub", "aud", "exp", "nbf", "iat", "jti",
    "cnf", "vct", "_sd", "_sd_alg",
  ]

  func toClaimUiModels(displayNames: [String: String]) throws -> [ClaimUiModel] {
    let claims = try recreateClaims().recreatedClaims.dictionaryValue

    return claims.keys
      .filter { !Self.reservedClaims.contains($0) }
      .sorted()
      .compactMap { name in
        guard let json = claims[name], json.exists() else {
          return nil
        }

        let displayName =
          displayNames[name] ?? name.replacingOccurrences(of: "_", with: " ").capitalized

        return ClaimUiModel(
          id: name,
          displayName: displayName,
          value: json.toClaimValue(
            path: name,
            displayNames: displayNames
          )
        )
      }
  }
}

private extension JSON {
  func toClaimValue(
    path: String,
    displayNames: [String: String]
  ) -> ClaimValue {
    switch type {
      case .string:
        if let date = try? Date(stringValue, strategy: .iso8601.year().month().day()) {
          return .date(date)
        }
        return .string(stringValue)
      case .number:
        if let i = int { return .int(i) }
        return .double(doubleValue)
      case .bool: return .bool(boolValue)
      case .array:
        return .array(
          arrayValue.enumerated()
            .map { index, item in
              let itemIdPath = "\(path).\(index)"
              return ClaimUiModel(
                id: itemIdPath,
                displayName: nil,
                value: item.toClaimValue(
                  path: path,
                  displayNames: displayNames
                )
              )
            }
        )
      case .dictionary:
        return .object(
          dictionaryValue
            .sorted { lhs, rhs in lhs.key < rhs.key }
            .map { key, value in
              let childPath = "\(path).\(key)"
              let displayName =
                displayNames[childPath]
                ?? key.replacingOccurrences(of: "_", with: " ").capitalized
              return ClaimUiModel(
                id: childPath,
                displayName: displayName,
                value: value.toClaimValue(
                  path: childPath,
                  displayNames: displayNames
                )
              )
            }
        )
      case .null: return .null
      default: return .null
    }
  }
}
