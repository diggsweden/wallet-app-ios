// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import OpenID4VCI

extension IssuanceAccessToken {
  func requestAuthorization(proofBuilder: any DpopProofProviding) -> RequestAuthorization {
    switch tokenType {
      case .dpop:
        .dpop(accessToken: accessToken, proofBuilder: proofBuilder)

      case .bearer, nil:
        .bearer(accessToken)
    }
  }
}
