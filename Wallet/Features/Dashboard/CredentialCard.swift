// SPDX-FileCopyrightText: 2026 diggsweden/wallet-app-ios
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct CredentialCard: View {
  let credential: Credential?
  @Environment(\.openURL) private var openURL
  @Environment(Router.self) private var router
  @Environment(\.theme) private var theme

  var body: some View {
    credentialContainer
      .frame(width: 320, height: 200)
      .background(
        RoundedRectangle(cornerRadius: 12, style: .continuous)
          .fill(credential == nil ? theme.colors.primaryAccent : theme.colors.secondary)
      )
  }

  @ViewBuilder
  private var credentialContainer: some View {
    if let credential {
      credentialButton(credential: credential)
    } else {
      addNewCredentialButton
    }
  }

  private func credentialButton(credential: Credential) -> some View {
    Button {
      router.go(to: .credentialDetails(credential))
    } label: {
      VStack(alignment: .leading, spacing: 14) {
        HStack(spacing: 10) {
          AsyncImage(url: credential.issuer.imageUrl) { phase in
            (phase.image ?? Image(.diggLogo))
              .resizable()
              .scaledToFit()
          }
          .frame(width: 40, height: 40)
          Text(credential.issuer.name).bold()
        }

        Text("ID-handling med \(credential.disclosures.count) attribut")
        Spacer()
        Text(credential.issuedAt, format: .dateTime.day().month().year())
          .textStyle(.caption)
          .frame(maxWidth: .infinity, alignment: .trailing)
      }
      .padding()
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .containerShape(Rectangle())
  }

  private var addNewCredentialButton: some View {
    Button {
      openURL(AppConfig.pidIssuerURL)
    } label: {
      VStack(spacing: 12) {
        Image(systemName: "plus.circle.fill")
          .resizable()
          .frame(width: 44, height: 44)
          .foregroundStyle(theme.colors.onSurface)
        Text("Lägg till attributsintyg")
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  let credential = Credential(
    issuer: IssuerDisplay(name: "testIssuer", info: nil, imageUrl: nil),
    sdJwt: "test",
    disclosures: [:],
    issuedAt: Date()
  )

  VStack {
    CredentialCard(credential: credential)
    CredentialCard(credential: nil)
  }
  .environment(Router())
}
