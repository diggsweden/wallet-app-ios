// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import OpenId4VCInterface

enum PresentationPhase {
  case loading
  case error(CaughtError)
  case ready
}

enum PresentationRoute: Hashable {
  case pin
  case success
}

struct PresentationItem: Identifiable {
  let id: String
  let required: Bool
  let claims: [ClaimUiModel]
  var isSelected: Bool

  init(candidate: PresentationCandidate, isSelected: Bool) {
    id = candidate.id
    required = candidate.required
    claims = candidate.claims
    self.isSelected = isSelected
  }
}
