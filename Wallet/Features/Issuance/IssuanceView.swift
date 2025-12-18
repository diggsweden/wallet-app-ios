import SwiftUI

struct IssuanceView: View {
  private let onSave: (Credential) async -> Void
  @State private var viewModel: IssuanceViewModel
  @Environment(Router.self) private var router
  @Environment(\.modelContext) private var modelContext
  @Environment(\.theme) private var theme
  @Environment(\.authPresentationAnchor) private var anchor
  @Environment(ToastViewModel.self) private var toastViewModel

  init(
    credentialOfferUri: String,
    walletUnitAttestation: String?,
    onSave: @escaping (Credential) async -> Void
  ) {
    self.onSave = onSave
    _viewModel = .init(
      wrappedValue: .init(
        credentialOfferUri: credentialOfferUri,
        wua: walletUnitAttestation ?? ""
      )
    )
  }

  var body: some View {
    VStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 10) {
          if case let .issuerFetched(offer) = viewModel.state,
            let issuerDisplayData = offer.credentialIssuerMetadata.display.first
          {
            CardView {
              VStack(alignment: .leading, spacing: 10) {
                AsyncImage(url: issuerDisplayData.logo?.uri)
                  .frame(maxWidth: .infinity, alignment: .center)
                  .padding(.bottom, 10)

                Text("Utfärdare:").font(.headline)
                Text(issuerDisplayData.name ?? "Inget namn")
              }
              .frame(maxWidth: .infinity, alignment: .leading)
            }
          }

          if case let .credentialFetched(credential) = viewModel.state {
            CardView {
              VStack(alignment: .leading, spacing: 10) {
                Text("Attribut:").font(.headline)
                ForEach(Array(credential.disclosures.values)) { disclosure in
                  DisclosureView(
                    title: disclosure.displayName,
                    value: disclosure.value
                  )
                }
              }
              .frame(maxWidth: .infinity, alignment: .leading)
            }
          }
        }
        .padding(.horizontal, 5)
        .frame(maxWidth: .infinity)
        .cornerRadius(8)
      }

      switch viewModel.state {
        case .initial:
          PrimaryButton("Hämta metadata") {
            Task {
              await viewModel.fetchIssuer()
            }
          }

        case .issuerFetched(let offer):
          PrimaryButton("Logga in", icon: "arrow.right.circle.fill") {
            Task {
              guard let anchor else {
                return
              }
              await viewModel.authorize(
                credentialOffer: offer,
                authPresentationAnchor: anchor
              )
            }
          }

        case .authorized(let request):
          PrimaryButton("Hämta ID-handling") {
            Task {
              await viewModel.fetchCredential(request)
            }
          }

        case .credentialFetched(let credential):
          PrimaryButton("Spara") {
            Task {
              await onSave(credential)
            }
            router.pop()
          }
      }
    }
    .navigationTitle(Text("Hämta attributsintyg"))
    .task {
      await viewModel.fetchIssuer()
    }
    .onChange(of: viewModel.error) { _, error in
      guard let error else {
        return
      }
      toastViewModel.showError(error.message)
    }
  }
}
