// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import OpenID4VP

enum Route: Hashable {
  case presentation(vpTokenData: ResolvedRequestData.VpTokenData)
  case issuance(credentialOfferUri: String)
  case credentialDetails(_ credential: Credential)
  case settings
}
