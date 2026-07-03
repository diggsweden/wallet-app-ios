// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import OpenID4VCI

enum IssuancePhase {
  case fetchingIssuer
  case readyToAuthorize(CredentialOffer)
  case authorizing
  case readyToSign(AuthorizedRequest)
  case readyToFetch(AuthorizedRequest, proof: String)
  case fetchingCredential
  case done(SavedCredential, [ClaimUiModel])
  case error(IssuanceRecovery)
}
