// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

enum Route: Hashable {
  case presentation(url: URL)
  case issuance(credentialOfferUri: String)
  case credentialDetails(_ credential: SavedCredential)
  case settings
}
