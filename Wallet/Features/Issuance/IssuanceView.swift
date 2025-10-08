import SwiftUI

struct IssuanceView: View {
  private let wallet: Wallet?
  @State private var viewModel: IssuanceViewModel
  @Environment(Router.self) private var router
  @Environment(\.modelContext) private var modelContext

  init(credentialOfferUri: String, wallet: Wallet?) {
    self.wallet = wallet
    _viewModel = State(
      wrappedValue: IssuanceViewModel(credentialOfferUri: credentialOfferUri)
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
          Button {
            Task {
              await viewModel.fetchIssuer()
            }
          } label: {
            Text("Fetch issuer metadata")
              .padding(6)
          }
          .buttonStyle(.borderedProminent)
          .tint(Theme.primaryColor)

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
                .foregroundColor(viewModel.authorizationCode.isEmpty ? .gray : Theme.primaryColor)
            }
            .disabled(viewModel.authorizationCode.isEmpty)
            .padding(.leading, 4)
          }
          .padding(24)

        case .authorized(let request):
          Button {
            Task {
              await viewModel.fetchCredential(request)
            }
          } label: {
            Text("Fetch credential")
              .padding(6)
          }
          .buttonStyle(.borderedProminent)
          .tint(Theme.primaryColor)

        case .credentialFetched(let credential):
          Button {
            wallet?.credential = credential
            try? modelContext.save()
            router.pop()
          } label: {
            Text("Save \(credential.disclosures.count) disclosures")
              .padding(6)
          }
          .buttonStyle(.borderedProminent)
          .tint(Theme.primaryColor)
      }
    }
    .navigationTitle(Text("Issue PID"))
    .task {
      await viewModel.fetchIssuer()
    }
  }
}
