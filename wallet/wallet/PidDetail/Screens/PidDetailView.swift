//
//  PidView.swift
//  wallet
//
import SwiftUI

struct PidDetailView: View {
    var credentialOfferUri: String

    @StateObject private var viewModel = PidDetailViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {

                    CardView {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Credential offer uri").font(.headline)
                            Text(credentialOfferUri)
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Button("Fetch metadata") {
                        Task {
                            await viewModel.fetch(url: credentialOfferUri)
                        }
                    }.buttonStyle(.bordered).padding()
                    Button("Fetch Issuer") {
                        Task {
                            await viewModel.issuer()
                        }
                    }.buttonStyle(.bordered).padding()

                    CardView {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Issuer").font(.headline)
                            Text("Credential Issuer Identifier").font(.headline)
                            Text(
                                viewModel.credentialOffer?
                                    .credentialIssuerMetadata
                                    .credentialIssuerIdentifier.url
                                    .absoluteString ?? "-"
                            )
                            Text("Batch credential issuance").font(.headline)
                            Text(
                                viewModel.credentialOffer?
                                    .credentialIssuerMetadata
                                    .batchCredentialIssuance?.batchSize
                                    .description ?? "-"
                            )
                            Text("Deferred credentil endpoint").font(.headline)
                            Text(
                                viewModel.credentialOffer?
                                    .credentialIssuerMetadata
                                    .deferredCredentialEndpoint?.url
                                    .absoluteString ?? "-"
                            )
                            Text("Deferred notification endpoint").font(
                                .headline
                            )
                            Text(
                                viewModel.credentialOffer?
                                    .credentialIssuerMetadata
                                    .notificationEndpoint?.url.absoluteString
                                    ?? "-"
                            )
                            Text("Credential endpoint").font(.headline)
                            Text(
                                viewModel.credentialOffer?
                                    .credentialIssuerMetadata.credentialEndpoint
                                    .url.absoluteString ?? "-"
                            )
                            Text("Pre Authorized Code").font(.headline)
                            Text(viewModel.preAuthCodeString ?? "-")
                            Text("txcode").font(.headline)
                            Text(viewModel.txCode ?? "-")
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }

                    CardView {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Accesstoken").font(.headline)
                            Text(viewModel.accessToken ?? "-")
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }

                    
                    Button("Fetch Credential") {
                        Task {
                            await viewModel.fetchCredential()
                        }
                    }.buttonStyle(.bordered).padding()

                    CardView {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Credential response").font(.headline)
                            Text("c_nonce").font(.headline)
                            Text("-")
                            Text("c_nonce_expires_in").font(.headline)
                            Text("-")
                            Text("credential").font(.headline)
                            Text(viewModel.credential?.credential ?? "-")
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }

                    CardView {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Decoded").font(.headline)
                            //loop over entries
                            ForEach(viewModel.decodedGrants, id: \.self) {
                                item in
                                Text(item)
                                    .font(.body)
                            }
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 5)
                .frame(maxWidth: .infinity)
                .cornerRadius(8)

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle(Text("Pid Detail"))
        }
    }
}

#Preview {
    PidDetailView(credentialOfferUri: "-").environment(
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
                    .fill(Color.secondary)
            )
            .padding(.horizontal)
    }
}
