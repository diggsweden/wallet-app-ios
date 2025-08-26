import SwiftUI

struct CredentialView: View {
  let credential: Credential?
  @Environment(\.openURL) var openURL
  @Environment(NavigationModel.self) var navigationModel

  var body: some View {
    Group {
      if let credential {
        Button {
          navigationModel.go(to: .credentialDetails(credential))
        } label: {
          VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
              AsyncImage(url: credential.issuer?.logo?.uri) { phase in
                (phase.image ?? Image(.diggLogo))
                  .resizable()
                  .scaledToFit()
              }
              .frame(width: 40, height: 40)
              Text(credential.issuer?.name ?? "Unknown").bold()
            }

            let description = credential.issuer?.description ?? "Identity document"
            Text("\(description) with \(credential.disclosures.count) disclosures")
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
      } else {
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
    .frame(width: 320, height: 200)
    .background(
      RoundedRectangle(cornerRadius: 12, style: .continuous)
        .fill(Theme.primaryColor.opacity(credential == nil ? 0.3 : 1))
    )
  }
}

#Preview {
  let credential = Credential(
    issuer: nil,
    sdJwt: "test",
    disclosures: [:],
    issuedAt: Date()
  )

  VStack {
    CredentialView(credential: credential)
    CredentialView(credential: nil)
  }
  .environment(NavigationModel())
}
