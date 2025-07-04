import SiopOpenID4VP
import SwiftUI

struct PresentationView: View {
  @State private var viewModel: PresentationViewModel

  init(vpTokenData: ResolvedRequestData.VpTokenData) {
    _viewModel = State(wrappedValue: PresentationViewModel(data: vpTokenData))
  }

  var body: some View {
    VStack {
      Text("Client:").bold()
      Text(viewModel.data.client.legalName ?? "No legal name")
      VStack {
        Text("Matches found:").bold()
        ForEach(viewModel.matches) { match in
          HStack {
            Text(match.claim.display?.first?.name ?? match.claim.path.description)
            Text(match.value)
          }
        }
      }
      .padding(.vertical, 12)
      if viewModel.success {
        Text("Sent vp token! ✅").tint(.green)
      }
    }
    .navigationTitle("Presenting")
    .toolbar {
      if !viewModel.matches.isEmpty {
        Button("Send") {
          Task {
            try? await viewModel.sendVpToken()
          }
        }
      }
    }
    .task {
      try? viewModel.matchCredentials()
    }
  }
}
