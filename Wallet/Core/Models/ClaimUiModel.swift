// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

enum ClaimValue {
  case string(String)
  case date(Date)
  case int(Int)
  case double(Double)
  case bool(Bool)
  case null
  case array([ClaimUiModel])
  case object([ClaimUiModel])
}

struct ClaimUiModel: Identifiable {
  let id: String
  let displayName: String?
  let value: ClaimValue
}
