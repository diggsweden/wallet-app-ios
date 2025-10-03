import SwiftUI

struct CredentialCard: View {
  let credential: Credential?
  @Environment(\.openURL) var openURL
  @Environment(NavigationModel.self) var navigationModel

  var body: some View {
    credentialContainer
      .frame(width: 320, height: 200)
      .background(
        RoundedRectangle(cornerRadius: 12, style: .continuous)
          .fill(Theme.primaryColor.opacity(credential == nil ? 0.3 : 1))
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
      navigationModel.go(to: .credentialDetails(credential))
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

        Text("Identity document with \(credential.disclosures.count) disclosures")
        Spacer()
        Text(credential.issuedAt, format: .dateTime.day().month().year())
          .font(.caption)
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
      guard let url = URL(string: "https://wallet.sandbox.digg.se/prepare-credential-offer")
      else {
        return
      }
      openURL(url)
    } label: {
      VStack(spacing: 8) {
        Image(systemName: "plus.circle.fill")
          .resizable()
          .frame(width: 44, height: 44)
          .foregroundStyle(Theme.primaryColor)
        Text("Add new credential")
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
  .environment(NavigationModel())
}
