// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import OpenID4VCI

enum IssuanceRecovery {
  case start
  case authorize(CredentialOffer)
  case fetchCredential(AuthorizedRequest, proof: String)
}
