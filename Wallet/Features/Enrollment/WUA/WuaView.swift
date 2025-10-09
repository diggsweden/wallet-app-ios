import JOSESwift
import SwiftUI

struct WuaView: View {
  let onSubmit: (String) throws -> Void
  private var viewModel: WuaViewModel
  @State private var result: Result<String, Error>?
  @State private var reload = 0

  init(
    walletId: UUID,
    keyTag: UUID,
    gatewayClient: GatewayClient,
    onSubmit: @escaping (String) throws -> Void
  ) {
    self.onSubmit = onSubmit
    viewModel = WuaViewModel(walletId: walletId, keyTag: keyTag, gatewayClient: gatewayClient)
  }

  var body: some View {
    content
      .toolbar {
        ToolbarItem(placement: .bottomBar) {
          toolbarButton
        }
      }
      .task(id: reload) {
        await fetchWua()
      }
  }

  @ViewBuilder private var content: some View {
    switch result {
      case .success:
        Text("Klart!")
      case .failure(let error):
        ErrorView(text: error.message, show: true)
      case nil:
        ProgressView("Hämtar WUA")
    }
  }

  @ViewBuilder private var toolbarButton: some View {
    switch result {
      case .success(let jwt):
        PrimaryButton(label: "Fortsätt") {
          do {
            try onSubmit(jwt)
          } catch {
            result = .failure(error)
          }
        }
      case .failure:
        PrimaryButton(label: "Försök igen") {
          self.reload += 1
        }
      case nil:
        EmptyView()
    }
  }

  private func fetchWua() async {
    result = nil
    do {
      let jwt = try await viewModel.fetchWua()
      result = .success(jwt)
    } catch {
      result = .failure(error)
    }
  }
}
