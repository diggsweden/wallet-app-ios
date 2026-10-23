// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Jose

enum LoteParser {
  static func parse(_ loteResponse: LoteResponse) throws -> Trust {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601

    switch loteResponse.type {
      case .json:
        return try decoder.decode(Trust.self, from: loteResponse.data)

      case .jose, .jwt:
        guard let compactString = String(bytes: loteResponse.data, encoding: .utf8) else {
          throw TrustListError.invalidEncoding
        }

        return try JwtUtil.parseJwt(from: compactString, decoder: decoder)
    }
  }
}
