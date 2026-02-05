import SwiftUI

struct IssuanceView: View {
  private let onSave: (Credential) async -> Void
  private let title: String
  @State private var viewModel: IssuanceViewModel
  @Environment(\.theme) private var theme
  @Environment(\.authPresentationAnchor) private var anchor
  @Environment(ToastViewModel.self) private var toastViewModel

  init(
    credentialOfferUri: String,
    title: String = "Hämta attributsintyg",
    onSave: @escaping (Credential) async -> Void
  ) {
    self.onSave = onSave
    self.title = title
    _viewModel = State(wrappedValue: .init(credentialOfferUri: credentialOfferUri))
  }

  var body: some View {
    VStack(spacing: 30) {
      if let display = viewModel.issuerDisplayData {
        IssuerDisplayView(issuerDisplayData: display)
      }

      if case let .credentialFetched(credential) = viewModel.state {
        CredentialView(disclosures: Array(credential.disclosures.values))
      }

      Spacer()

      button
    }
    .navigationTitle(title)
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

  private var button: some View {
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
        }
    }
  }
}
