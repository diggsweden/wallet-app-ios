// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI
import eudi_lib_sdjwt_swift

struct CredentialDetailsView: View {
  let credential: SavedCredential

  var body: some View {
    ScrollView {
      VStack(spacing: 30) {
        IssuerDisplayView(issuerDisplayData: credential.issuer)
        if let claims = try? credential.getClaimUiModels() {
          CredentialView(claims: claims)
        }
      }
    }
    .navigationTitle("Attributsintyg")
    .navigationBarTitleDisplayMode(.inline)
  }
}
