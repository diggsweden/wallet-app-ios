// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

struct LoteResponse: Sendable {
  let data: Data
  let type: LoteContentType
}

enum LoteContentType: String, Sendable {
  case json = "application/json"
  case jose = "application/jose"
  case jwt = "application/jwt"
}
