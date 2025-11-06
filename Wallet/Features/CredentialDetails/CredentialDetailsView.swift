import SwiftUI

struct CredentialDetailsView: View {
  let credential: Credential

  var body: some View {
    ScrollView {
      CardView {
        VStack(alignment: .leading, spacing: 12) {
          Text("**Utfärdare:**\n\(credential.issuer.name)")
            .textStyle(.bodyLarge)
          Text("**Attribut:**")
            .textStyle(.bodyLarge)
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
