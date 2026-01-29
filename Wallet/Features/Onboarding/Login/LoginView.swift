import SwiftUI

struct LoginView: View {
  let onSubmit: (String) -> Void
  @Environment(\.authPresentationAnchor) private var anchor
  @Environment(ToastViewModel.self) private var toastViewModel
  @State var viewModel = LoginViewModel()

  var body: some View {
    VStack {
      Text("För att kunna registrera ett konto behöver du först logga in.")
      Spacer()
      PrimaryButton("Logga in", icon: "arrow.right.circle.fill") {
        Task {
          do {
            let oidcSessionId = try await viewModel.login(anchor: anchor)
            onSubmit(oidcSessionId)
          } catch {
            toastViewModel.showError(error.message)
          }
        }
      }
    }
  }
}
