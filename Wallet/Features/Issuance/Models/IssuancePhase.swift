// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces

enum IssuancePhase {
  case fetchingIssuer
  case readyToAuthorize
  case authorizing
  case readyToSign
  case readyToFetch
  case fetchingCredential
  case done(SavedCredential, [ClaimUiModel])
  case error(IssuanceRecovery, CaughtError)
}
