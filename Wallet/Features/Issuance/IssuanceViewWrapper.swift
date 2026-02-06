import SwiftUI

struct IssuanceViewWrapper: View {
  let credentialOfferUri: String
  let onSave: (Credential) async -> Void

  var body: some View {
    GeometryReader { proxy in
      ScrollView {
        IssuanceView(credentialOfferUri: credentialOfferUri, onSave: onSave)
          .frame(
            maxWidth: .infinity,
            minHeight: proxy.size.height,
            alignment: .top
          )
      }
    }
  }
}
