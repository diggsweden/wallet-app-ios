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
