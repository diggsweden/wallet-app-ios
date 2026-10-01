// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import DesignSystem
import SdJwt
import SwiftUI

struct CredentialDetailsView: View {
  @Environment(\.theme) private var theme

  let credential: SavedCredential

  var body: some View {
    ScrollView {
      VStack(spacing: 30) {
        IssuerDisplayView(issuerDisplayData: credential.issuer)
        if let claims = try? credential.getClaimUiModels() {
          CredentialView(claims: claims)
        }
      }
      .padding(.horizontal, theme.horizontalPadding)
    }
    .navigationTitle("Attributsintyg")
    .navigationBarTitleDisplayMode(.inline)
  }
}
