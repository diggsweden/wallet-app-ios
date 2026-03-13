// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import eudi_lib_sdjwt_swift

extension SavedCredential {
  func getClaimUiModels() throws -> [ClaimUiModel] {
    try CompactParser()
      .getSignedSdJwt(serialisedString: compactSerialized)
      .toClaimUiModels(displayNames: claimDisplayNames)
  }
}
