// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

enum Deeplink {
  case issuance(URL)
  case presentation(URL)

  init?(_ url: URL) {
    switch url.scheme {
      case "openid-credential-offer", "haip-vci":
        self = .issuance(url)

      case "openid4vp", "eudi-openid4vp", "haip-vp":
        self = .presentation(url)

      default:
        return nil
    }
  }
}
