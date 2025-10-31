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
        EnrollmentBottomToolbarButton {
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
        Text("Redo!")
      case .failure(let error):
        ErrorView(text: error.message, show: true)
      case nil:
        ProgressView("Hämtar intyg")
    }
  }

  @ViewBuilder
  private var toolbarButton: some View {
    switch result {
      case .success(let jwt):
        PrimaryButton("enrollmentNext") {
          do {
            try onSubmit(jwt)
          } catch {
            result = .failure(error)
          }
        }
      case .failure:
        PrimaryButton("Försök igen") {
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
