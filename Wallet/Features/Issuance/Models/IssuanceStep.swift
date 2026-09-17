// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import OpenId4VCInterface

enum IssuanceStep {
  case loadingCredentialOffer
  case preparingToAuthorize
  case authorizing(WebAuthenticate)
  case awaitingPin
  case creatingKey(pin: String)
  case signingProof(proofKey: ProofKey, pin: String)
  case fetchingCredential
  case done(IssuedCredential)
}
