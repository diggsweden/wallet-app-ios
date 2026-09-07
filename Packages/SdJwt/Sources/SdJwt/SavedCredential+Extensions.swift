// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import Foundation

extension SavedCredential {
  public func getClaimUiModels() throws -> [ClaimUiModel] {
    try SdJwtVc.claimUiModels(
      compactSerialized: compactSerialized,
      displayNames: claimDisplayNames,
    )
  }
}
