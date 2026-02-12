// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct CredentialDetailsView: View {
  let credential: Credential

  var body: some View {
    ScrollView {
      VStack(spacing: 30) {
        IssuerDisplayView(issuerDisplayData: credential.issuer)
        CredentialView(disclosures: Array(credential.disclosures.values))
      }
    }
    .navigationTitle("Attributsintyg")
    .navigationBarTitleDisplayMode(.inline)
  }
}
