import SwiftUI

let diggPrimaryColor = Color(red: 214 / 255, green: 132 / 255, blue: 42 / 255)

struct IssuanceView: View {
  @State private var viewModel: IssuanceViewModel
  @Environment(NavigationModel.self) var navigationModel

  init(credentialOfferUri: String) {
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
                Text("PID info:").font(.headline)
                ForEach(Array(credential.disclosures.values)) { disclosure in
                  if let display = disclosure.claim.display?.first {
                    Text(display.name ?? "No name").bold()
                  }
                  if let mandatory = disclosure.claim.mandatory {
                    Text("Mandatory: \(mandatory)")
                  }
                  Text("Value: ") + Text(disclosure.value).bold()
                  Divider()
                }
                .font(.body)
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
          .tint(diggPrimaryColor)

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
                .foregroundColor(viewModel.authorizationCode.isEmpty ? .gray : diggPrimaryColor)
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
          .tint(diggPrimaryColor)

        case .credentialFetched(let credential):
          Button {
            viewModel.saveCredential(credential)
            navigationModel.pop()
          } label: {
            Text("Save \(credential.disclosures.count) claims")
              .padding(6)
          }
          .buttonStyle(.borderedProminent)
          .tint(diggPrimaryColor)
      }
    }
    .navigationTitle(Text("Issue PID"))
    .task {
      await viewModel.fetchIssuer()
    }
  }
}

struct CardView<Content: View>: View {
  let content: () -> Content

  var body: some View {
    content()
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 12, style: .continuous)
          .fill(diggPrimaryColor.opacity(0.2))
      )
      .padding(.horizontal)
  }
}
