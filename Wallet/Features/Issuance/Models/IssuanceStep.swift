// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import OpenId4VCInterface

typealias ProofKeyManager = ProofSigner & ProofKeyStore & AnyObject

enum IssuanceStep {
  case loadingCredentialOffer
  case preparingToAuthorize
  case authorizing(WebAuthenticator)
  case awaitingPin
  case authenticatingPin(any ProofKeyManager)
  case creatingKey(any ProofKeyManager)
  case signingProof(proofKey: ProofKey, signer: any ProofKeyManager)
  case fetchingCredential(proofKey: ProofKey, signer: any ProofKeyManager)
  case savingCredential(
    IssuedCredential,
    proofKey: ProofKey,
    signer: any ProofKeyManager,
  )
  case awaitingCompletion(IssuedCredential)
  case complete(IssuedCredential)
}

extension IssuanceStep {
  var retryStep: IssuanceStep {
    switch self {
      case .authorizing: .preparingToAuthorize

      case .authenticatingPin: .awaitingPin

      case let .fetchingCredential(proofKey, signer):
        .signingProof(proofKey: proofKey, signer: signer)

      case .loadingCredentialOffer,
        .preparingToAuthorize,
        .awaitingPin,
        .creatingKey,
        .signingProof,
        .savingCredential,
        .awaitingCompletion,
        .complete:
        self
    }
  }

  var pendingKey: (ProofKey.ID, any ProofKeyStore)? {
    switch self {
      case let .signingProof(proofKey, signer),
        let .fetchingCredential(proofKey, signer):
        (proofKey.id, signer)

      case let .savingCredential(_, proofKey, signer):
        (proofKey.id, signer)

      case .loadingCredentialOffer,
        .preparingToAuthorize,
        .authorizing,
        .awaitingPin,
        .authenticatingPin,
        .creatingKey,
        .awaitingCompletion,
        .complete:
        nil
    }
  }
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

      case let (.authenticatingPin(lhsSigner), .authenticatingPin(rhsSigner)):
        return lhsSigner === rhsSigner

      case let (.creatingKey(lhsSigner), .creatingKey(rhsSigner)):
        return lhsSigner === rhsSigner

      case let (.signingProof(lhsProofKey, lhsSigner), .signingProof(rhsProofKey, rhsSigner)):
        return lhsProofKey == rhsProofKey && lhsSigner === rhsSigner

      case let (
        .fetchingCredential(lhsProofKey, lhsSigner),
        .fetchingCredential(rhsProofKey, rhsSigner),
      ):
        return lhsProofKey == rhsProofKey && lhsSigner === rhsSigner

      case let (
        .savingCredential(lhsCredential, lhsProofKey, lhsSigner),
        .savingCredential(rhsCredential, rhsProofKey, rhsSigner),
      ):
        return lhsCredential == rhsCredential && lhsSigner === rhsSigner
          && lhsProofKey == rhsProofKey

      case let (.awaitingCompletion(lhsCredential), .awaitingCompletion(rhsCredential)):
        return lhsCredential == rhsCredential

      case let (.complete(lhsCredential), .complete(rhsCredential)):
        return lhsCredential == rhsCredential

      default:
        return false
    }
  }
}
