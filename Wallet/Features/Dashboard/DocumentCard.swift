// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct DocumentCard: View {
  let credential: SavedCredential
  @Environment(Router.self) private var router
  @Environment(\.theme) private var theme

  var body: some View {
    Button {
      router.go(to: .credentialDetails(credential))
    } label: {
      HStack(spacing: 10) {
        Image(systemName: "person.text.rectangle")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 29)
          .foregroundStyle(.white)
          .accessibilityHidden(true)
        Text(credential.displayData?.name ?? "Dokument")
          .textStyle(.h4)
          .foregroundStyle(.white)
      }
      .padding(20)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(theme.colors.layerAccent, in: RoundedRectangle(cornerRadius: theme.cornerRadius))
    }
  }
}

#Preview {
  let credential = SavedCredential(
    issuer: IssuerDisplay(name: "testIssuer", info: nil, imageUrl: nil),
    compactSerialized: "",
    claimDisplayNames: [:],
    claimsCount: 15,
    issuedAt: Date(),
    type: "",
    displayData: CredentialDisplayData(name: "Körkort"),
  )

  DocumentCard(credential: credential)
    .environment(Router())
    .themed
}
