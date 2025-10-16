import SwiftUI

struct IssuanceView: View {
  private let onSave: (Credential) async -> Void
  @State private var viewModel: IssuanceViewModel
  @Environment(Router.self) private var router
  @Environment(\.modelContext) private var modelContext
  @Environment(\.theme) private var theme

  init(
    credentialOfferUri: String,
    keyTag: UUID,
    walletUnitAttestation: String?,
    onSave: @escaping (Credential) async -> Void
  ) {
    self.onSave = onSave
    _viewModel = .init(
      wrappedValue: .init(
        credentialOfferUri: credentialOfferUri,
        keyTag: keyTag,
        wua: walletUnitAttestation ?? ""
      )
    )
  }

  var body: some View {
    VStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 10) {
          if let metadata = viewModel.issuerMetadata {
            CardView {
              VStack(alignment: .leading, spacing: 10) {
                if let display = metadata.display.first {
                  AsyncImage(url: display.logo?.uri)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 10)

                  Text("Issuer:").font(.headline)
                  Text(display.name ?? "No name")

                  Text("Description:").font(.headline)
                  Text(display.description ?? "No description")
                }

                Text("Credential endpoint").font(.headline)
                Text(
                  metadata.credentialEndpoint.url.absoluteString
                )
              }
              .frame(maxWidth: .infinity, alignment: .leading)
            }
          }

          if case let .credentialFetched(credential) = viewModel.state {
            CardView {
              VStack(alignment: .leading, spacing: 10) {
                Text("Disclosures:").font(.headline)
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
          HStack {
            TextField("Enter authorization code", text: $viewModel.authorizationCode)
              .textFieldStyle(.roundedBorder)
              .onSubmit {
                Task {
                  await viewModel.authorize(
                    with: viewModel.authorizationCode,
                    credentialOffer: offer
                  )
                }
              }
            Button {
              Task {
                await viewModel.authorize(with: viewModel.authorizationCode, credentialOffer: offer)
              }
            } label: {
              Image(systemName: "arrow.right.circle.fill")
                .font(.title2)
                .foregroundColor(viewModel.authorizationCode.isEmpty ? .gray : theme.colors.primary)
            }
            .disabled(viewModel.authorizationCode.isEmpty)
            .padding(.leading, 4)
          }
          .padding(24)

        case .authorized(let request):
          PrimaryButton("Hämta ID-handling") {
            Task {
              await viewModel.fetchCredential(request)
            }
          }

        case .credentialFetched(let credential):
          PrimaryButton("Spara \(credential.disclosures.count) attribut") {
            Task {
              await onSave(credential)
            }
            router.pop()
          }
      }
    }
    .navigationTitle(Text("Issue PID"))
    .task {
      await viewModel.fetchIssuer()
    }
  }
}
