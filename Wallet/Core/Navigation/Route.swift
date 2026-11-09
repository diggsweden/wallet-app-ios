// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import Foundation

enum Route: Hashable {
  case issuance(url: URL)
  case credentialDetails(_ credential: SavedCredential)
}
