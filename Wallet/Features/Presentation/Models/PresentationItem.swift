// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import OpenId4VCInterface

struct PresentationItem: Identifiable {
  let id: String
  let required: Bool
  let credentialUiModel: CredentialUiModel
  var isSelected: Bool

  init(candidate: PresentationCandidate, isSelected: Bool) {
    id = candidate.id
    required = candidate.required
    credentialUiModel = candidate.credentialUiModel
    self.isSelected = isSelected
  }
}
