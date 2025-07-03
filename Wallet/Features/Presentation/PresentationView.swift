import SiopOpenID4VP
import SwiftUI

struct PresentationView: View {
  @State private var viewModel: PresentationViewModel
  @Environment(NavigationModel.self) var navigationModel

  init(vpTokenData: ResolvedRequestData.VpTokenData, credential: Credential) {
    _viewModel = State(
      wrappedValue: PresentationViewModel(data: vpTokenData, credential: credential)
    )
  }

  var body: some View {
    VStack {
      ScrollView {
        CardView {
          Text(
            "Do you want to share data with \(viewModel.data.client.legalName ?? "Unknown")?"
          )
          .frame(maxWidth: .infinity)
        }
        CardView {
          VStack(spacing: 12) {
            Text("Disclosures to share:").bold()
            ForEach(viewModel.selectedDisclosures) { match in
              DisclosureView(
                title: match.disclosure.claim.display?.first?.name ?? "",
                value: match.disclosure.value,
                onToggle: { newValue in
                  if let index = viewModel.selectedDisclosures
                    .firstIndex(where: { $0.id == match.id })
                  {
                    viewModel.selectedDisclosures[index].isSelected = newValue
                  }
                }
              )
            }
          }
        }
      }
      Button {
        Task {
          try? await viewModel.sendDisclosures()
          navigationModel.pop()
        }
      } label: {
        Text("Send")
          .padding(6)
      }
      .buttonStyle(.borderedProminent)
      .tint(Theme.primaryColor)
      .disabled(viewModel.selectedDisclosures.filter(\.self.isSelected).isEmpty)
    }
    .navigationTitle("Presenting")
    .task {
      try? viewModel.matchDisclosures()
    }
  }
}
