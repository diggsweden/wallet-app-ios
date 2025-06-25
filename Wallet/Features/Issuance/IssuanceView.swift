import SwiftUI

let diggPrimaryColor = Color(red: 214 / 255, green: 132 / 255, blue: 42 / 255)

struct IssuanceView: View {
  @StateObject private var viewModel: IssuanceViewModel

  init(credentialOfferUri: String) {
    _viewModel = StateObject(
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

          if let claims = viewModel.pidClaims {
            CardView {
              VStack(alignment: .leading, spacing: 10) {
                Text("PID info:").font(.headline)
                ForEach(claims) { claim in
                  if let display = claim.claim.display?.first {
                    Text(display.name ?? "No name").bold()
                  }
                  if let mandatory = claim.claim.mandatory {
                    Text("Mandatory: \(mandatory)")
                  }
                  Text("Value: ") + Text(claim.value).bold()
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

      if let accessToken = viewModel.accessToken, let url = viewModel.issuerMetadata?.credentialEndpoint.url {
        Button {
          Task {
            await viewModel.fetchCredential(accessToken, url: url)
          }
        } label: {
          Text("Fetch credential")
            .padding(6)
        }
        .buttonStyle(.borderedProminent)
        .tint(diggPrimaryColor)
      } else {
        Button {
          Task {
            await viewModel.fetchMetadata()
          }
        } label: {
          Text("Fetch issuer metadata")
            .padding(6)
        }
        .buttonStyle(.borderedProminent)
        .tint(diggPrimaryColor)
      }
    }
    .navigationTitle(Text("Pid Detail"))
    .task {
      await viewModel.fetchMetadata()
    }
  }
}

#Preview {
  IssuanceView(credentialOfferUri: "-")
    .environment(
      \.locale,
      .init(identifier: "swe")
    )
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
