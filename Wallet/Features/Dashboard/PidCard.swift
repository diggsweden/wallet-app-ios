// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct PidCard: View {
  let credential: SavedCredential
  @Environment(Router.self) private var router
  @Environment(\.theme) private var theme

  var body: some View {
    Button {
      router.go(to: .credentialDetails(credential))
    } label: {
      HStack(alignment: .center, spacing: 24) {
        Image(systemName: "person.text.rectangle")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 29)
          .padding(14)
          .background(.white, in: .circle)
          .foregroundStyle(Theme.light.colors.textPrimary)
          .accessibilityHidden(true)

        VStack(alignment: .leading, spacing: 14) {
          Text("Min ID-handling").textStyle(.h5)
          Text("Uppdaterad: \(credential.issuedAt, format: .dateTime.day().month().year())")
            .textStyle(.bodySmall)
        }
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 38)
      .contentShape(Rectangle())
    }
    .background(
      RoundedRectangle(cornerRadius: 12, style: .continuous)
        .fill(theme.colors.pidBackground)
    )
    .buttonStyle(.plain)
    .containerShape(Rectangle())
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
    displayData: nil,
  )

  VStack {
    PidCard(credential: credential)
  }
  .environment(Router())
}
