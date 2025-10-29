import SiopOpenID4VP
import SwiftUI

struct PresentationView: View {
  @State private var viewModel: PresentationViewModel
  @Environment(Router.self) private var router
  @Environment(\.theme) private var theme

  init(vpTokenData: ResolvedRequestData.VpTokenData, keyTag: UUID, credential: Credential?) {
    _viewModel = State(
      wrappedValue: .init(data: vpTokenData, keyTag: keyTag, credential: credential)
    )
  }

  var body: some View {
    if viewModel.credential != nil {
      presentView
    } else {
      errorView
    }
  }

  private var presentView: some View {
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
                title: match.disclosure.displayName,
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
      PrimaryButton("Skicka") {
        Task {
          try? await viewModel.sendDisclosures()
          router.pop()
        }
      }
      .disabled(viewModel.selectedDisclosures.filter(\.self.isSelected).isEmpty)
    }
    .navigationTitle("Presenting")
    .task {
      try? viewModel.matchDisclosures()
    }
  }

  private var errorView: some View {
    VStack(spacing: 24) {
      Text("Hittade ingen ID-handling!")
        .foregroundStyle(Color.red)
      PrimaryButton("Gå tillbaka") {
        router.pop()
      }
    }
  }
}
