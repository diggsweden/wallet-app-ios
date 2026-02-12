// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import OpenID4VP

extension ResolvedRequestData.VpTokenData: @retroactive Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(nonce)
  }

  public static func == (
    lhs: ResolvedRequestData.VpTokenData,
    rhs: ResolvedRequestData.VpTokenData
  ) -> Bool {
    return lhs.nonce == rhs.nonce
  }
}
