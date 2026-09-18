// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import OpenId4VCInterface

typealias ProofKeyManager = ProofSigner & ProofKeyStore & AnyObject

enum IssuanceStep {
  case loadingCredentialOffer
  case preparingToAuthorize
  case authorizing(WebAuthenticate)
  case awaitingPin
  case authenticating(any ProofKeyManager)
  case creatingKey(any ProofKeyManager)
  case signingProof(proofKey: ProofKey, signer: any ProofKeyManager)
  case fetchingCredential(proofKey: ProofKey)
  case done(IssuedCredential)
}

extension IssuanceStep: Equatable {
  static func == (lhs: IssuanceStep, rhs: IssuanceStep) -> Bool {
    switch (lhs, rhs) {
      case (.loadingCredentialOffer, .loadingCredentialOffer):
        return true

      case (.preparingToAuthorize, .preparingToAuthorize):
        return true

      case (.authorizing, .authorizing):
        return true

      case (.awaitingPin, .awaitingPin):
        return true

      case let (.authenticating(lhsSigner), .authenticating(rhsSigner)):
        return lhsSigner === rhsSigner

      case let (.creatingKey(lhsSigner), .creatingKey(rhsSigner)):
        return lhsSigner === rhsSigner

      case let (.signingProof(lhsProofKey, lhsSigner), .signingProof(rhsProofKey, rhsSigner)):
        return lhsProofKey == rhsProofKey && lhsSigner === rhsSigner

      case (.fetchingCredential, .fetchingCredential):
        return true

      case let (.done(lhsCredential), .done(rhsCredential)):
        return lhsCredential == rhsCredential

      default:
        return false
    }
  }
}
