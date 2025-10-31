import SwiftUI

struct CredentialDetailsView: View {
  let credential: Credential

  var body: some View {
    ScrollView {
      CardView {
        VStack(spacing: 12) {
          Text(credential.issuer.name).bold()
          Text("Available disclosures:")
          ForEach(Array(credential.disclosures.values)) { disclosure in
            DisclosureView(
              title: disclosure.displayName,
              value: disclosure.value
            )
          }
        }
      }
    }
  }
}
