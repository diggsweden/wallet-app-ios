// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

struct DpopProofClaims: Codable {
  let jti: String
  let htm: String
  let htu: String
  let nonce: String?
  let ath: String?
}
